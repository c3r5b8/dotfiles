// ==UserScript==
// @name         Reddit - Uses system theme
// @namespace    https://tampermonkey.net/
// @version      0.1
// @description  If system is light → set cookie "theme"=1, if dark → "theme"=2, then reload
// @author       c3r5b8
// @match        *://*.reddit.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    'use strict';

    function getSystemTheme() {
        return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
            ? 2   // dark
            : 1;  // light
    }

    function getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) {
            return parts.pop().split(';').shift();
        }
        return null;
    }

    function setCookie(name, value, days = 400) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        const expires = `; expires=${date.toUTCString()}`;
        document.cookie = `${name}=${value}${expires}; path=/; domain=.reddit.com; SameSite=Lax`;
    }

    const desired = getSystemTheme();
    const current = getCookie('theme');

    if (current !== String(desired)) {
        setCookie('theme', desired);
        setTimeout(() => {
            window.location.reload(true);
        }, 50);
    }
})();
