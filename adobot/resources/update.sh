#!/bin/bash

NAMESPACE="adobot"
INSTALL_DIR="/home/$USER/.frankpoon"
REPO_DIR="$INSTALL_DIR/repos"

main() {
  git -C "$REPO_DIR/$NAMESPACE" pull

  pm2 restart $NAMESPACE
}

main
