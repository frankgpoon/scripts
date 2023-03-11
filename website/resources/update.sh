#!/bin/bash

NAMESPACE="website"
REPO_DIR="/home/$USER/repos"
RESOURCE_DIR="$INSTALL_DIR/resources"

WEBSITE_REPO_NAME="frankpoon"
FSB_REPO_NAME="fsb"


main() {
  git -C "$REPO_DIR/$WEBSITE_REPO_NAME" pull
  git -C "$REPO_DIR/$FSB_REPO_NAME" pull

  caddy reload --config "$RESOURCE_DIR/$NAMESPACE/Caddyfile"
}

main