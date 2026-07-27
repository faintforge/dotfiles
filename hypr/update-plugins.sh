#!/usr/bin/env bash

cd "$HOME/.config/hypr/"

# split-monitor-workspaces
git submodule update --remote --rebase --recursive plugins/split-monitor-workspaces
cd "plugins/split-monitor-workspaces"
version="$(hyprland --version | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
git checkout "$version"
if [ $? != 0 ]; then
    echo "split-monitor-workspaces $version not available!"
fi
