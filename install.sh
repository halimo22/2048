#!/usr/bin/env bash
# Install nginx and serve the 2048 game as the default site.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT=/usr/share/nginx/html
CONF="server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root $WEB_ROOT;
    index index.html;
    server_name _;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
"

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo rm -f /etc/nginx/sites-enabled/default
    echo "$CONF" | sudo tee /etc/nginx/sites-available/2048 >/dev/null
    sudo ln -sf /etc/nginx/sites-available/2048 /etc/nginx/sites-enabled/2048
elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
    PKG=$(command -v dnf || command -v yum)
    sudo "$PKG" install -y nginx
    sudo rm -f /etc/nginx/conf.d/default.conf
    echo "$CONF" | sudo tee /etc/nginx/conf.d/2048.conf >/dev/null
elif command -v brew >/dev/null 2>&1; then
    brew install nginx
    WEB_ROOT="$(brew --prefix nginx)/html"
else
    echo "No supported package manager (apt-get, dnf/yum, or brew) found." >&2
    exit 1
fi

sudo mkdir -p "$WEB_ROOT"
sudo rm -rf "${WEB_ROOT:?}"/*
sudo cp -r "$SRC_DIR"/. "$WEB_ROOT"/

if command -v systemctl >/dev/null 2>&1; then
    sudo nginx -t
    sudo systemctl enable nginx
    sudo systemctl restart nginx
else
    brew services restart nginx
fi

echo "2048 is now served by nginx at $WEB_ROOT"
