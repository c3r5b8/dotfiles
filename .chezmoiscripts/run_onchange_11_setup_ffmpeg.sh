#!/usr/bin/env bash
if ! rpm -q --quiet ffmpeg; then
    sudo rpm-ostree override remove \
        fdk-aac-free \
        libavcodec-free \
        libavdevice-free \
        libavfilter-free \
        libavformat-free \
        libavutil-free \
        libswresample-free \
        libswscale-free \
        ffmpeg-free \
        --install ffmpeg
fi
