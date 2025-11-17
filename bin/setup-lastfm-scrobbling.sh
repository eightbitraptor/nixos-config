#!/usr/bin/env bash

# Setup script for Last.fm scrobbling with mpdscribble
# This creates a secure password file outside the Nix store

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/mpd-config.nix"
PASSWORD_DIR="$HOME/.config/mpdscribble"
PASSWORD_FILE="$PASSWORD_DIR/lastfm-password"
# Create directory if it doesn't exist
if [ ! -d "$PASSWORD_DIR" ]; then
    echo "Creating directory: $PASSWORD_DIR"
    mkdir -p "$PASSWORD_DIR"
    chmod 700 "$PASSWORD_DIR"
fi

# Check if password file already exists
if [ -f "$PASSWORD_FILE" ]; then
    echo "Warning: Password file already exists at $PASSWORD_FILE"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing password file."
    else
        rm "$PASSWORD_FILE"
    fi
fi

echo ""
read -p "Enter your Last.fm username: " LASTFM_USERNAME

if [ ! -f "$PASSWORD_FILE" ]; then
    read -s -p "Enter your Last.fm password: " LASTFM_PASSWORD
    echo ""

    # Generate MD5 hash (Last.fm's expected format)
    echo ""
    echo "Creating secure password file..."
    echo -n "$LASTFM_PASSWORD" | md5sum | cut -d' ' -f1 > "$PASSWORD_FILE"

    # Secure the file
    chmod 600 "$PASSWORD_FILE"
    echo "Password file created"
fi
