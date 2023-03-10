#!/bin/bash

WEBSITE_REPO_NAME="frankpoon"
FSB_REPO_NAME="fsb"

REPO_DIR="/home/$USER/repos"

main() {
  git -C "$REPO_DIR/$WEBSITE_REPO_NAME" pull
  git -C "$REPO_DIR/$FSB_REPO_NAME" pull

  caddy reload --config "$CONFIG_DIR/Caddyfile"
}