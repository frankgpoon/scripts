#!/bin/bash

REPO_NAME="adobot"
REPO_DIR="/home/$USER/repos"

main() {
  git -C "$REPO_DIR/$REPO_NAME" pull

  pm2 restart $REPO_NAME
}

main
