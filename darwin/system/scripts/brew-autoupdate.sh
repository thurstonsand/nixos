#!/bin/bash

# Check if autoupdate is already running
if ! /opt/homebrew/bin/brew autoupdate status 2>/dev/null | grep -q "Autoupdate is installed and running"; then
    /opt/homebrew/bin/brew autoupdate start 86400 --cleanup
fi
