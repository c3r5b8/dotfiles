var allPanels = panels();

for (var i = 0; i < allPanels.length; i++) {
    allPanels[i].remove();
}

var panel = new Panel;
panel.location = "top";
panel.height = 32;
panel.alignment = "center";
panel.floating = false;
panel.hiding = "none";
panel.lengthMode = "fill";
panel.opacity = "translucent";
panel.screen = 0;

var kickoff = panel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("alphaSort", "true");
kickoff.writeConfig("applicationsDisplay", "0");
kickoff.writeConfig("favoritesPortedToKAstats", "true");
kickoff.writeConfig("forceDarkMode", "false");
kickoff.writeConfig("icon", "start-here-kde-symbolic");
kickoff.writeConfig("highlightNewlyInstalledApps", "false");
kickoff.writeConfig("recentOrdering", "1");
kickoff.writeConfig("systemFavorites", "suspend\\,logout\\,reboot\\,shutdown");
kickoff.reloadConfig();

var pager = panel.addWidget("org.kde.plasma.pager");
pager.currentConfigGroup = ["General"];
pager.writeConfig("displayedText", "Number");
pager.writeConfig("showOnlyCurrentScreen", "true");
pager.writeConfig("wrapPage", "true");
pager.reloadConfig();

panel.addWidget("org.kde.plasma.panelspacer");

var systray = panel.addWidget("org.kde.plasma.systemtray");
systray.currentConfigGroup = ["General"];
systray.writeConfig("shownItems", "org.kde.plasma.volume,org.kde.plasma.networkmanagement,org.kde.plasma.bluetooth,org.kde.plasma.battery");
systray.writeConfig("hiddenItems", "org.kde.plasma.weather");
systray.reloadConfig();

var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("dateDisplayFormat", "BesideTime");
clock.writeConfig("enabledCalendarPlugins", "astronomicalevents");
clock.writeConfig("showWeekNumbers", "true");
clock.reloadConfig();

var allDesktops = desktops();

for (var i = 0; i < allDesktops.length; i++) {
    var desktop = allDesktops[i];

    desktop.wallpaperPlugin = "org.kde.image";

    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktop.writeConfig("Image", "file:///var/home/c3r5b8/.local/share/wallpapers/Greens/");
    desktop.writeConfig("SlidePaths", "/home/c3r5b8/.local/share/wallpapers/,/usr/share/wallpapers/");

    desktop.reloadConfig();
}
