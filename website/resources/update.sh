#!/bin/bash

NAMESPACE="website"
INSTALL_DIR="/home/$USER/.frankpoon"
REPO_DIR="$INSTALL_DIR/repos"
RESOURCE_DIR="$INSTALL_DIR/resources"

WEBSITE_REPO_NAME="frankpoon"
FSB_REPO_NAME="fsb"


main() {
  git -C "$REPO_DIR/$WEBSITE_REPO_NAME" pull
  git -C "$REPO_DIR/$FSB_REPO_NAME" pull

  caddy reload --config "$RESOURCE_DIR/$NAMESPACE/Caddyfile"
}

main
