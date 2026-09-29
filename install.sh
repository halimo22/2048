#!/usr/bin/env bash
# Install nginx and serve the 2048 game as the default site.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y nginx
    WEB_ROOT=/var/www/html
elif command -v brew >/dev/null 2>&1; then
    brew install nginx
    WEB_ROOT="$(brew --prefix nginx)/html"
else
    echo "No supported package manager (apt-get or brew) found." >&2
    exit 1
fi

sudo rm -rf "${WEB_ROOT:?}"/*
sudo cp -r "$SRC_DIR"/. "$WEB_ROOT"/

if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable nginx
    sudo systemctl restart nginx
else
    brew services restart nginx
fi

echo "2048 is now served by nginx at $WEB_ROOT"
