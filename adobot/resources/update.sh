#!/bin/bash

NAMESPACE="adobot"
REPO_DIR="/home/$USER/repos"

main() {
  git -C "$REPO_DIR/$NAMESPACE" pull

  pm2 restart $NAMESPACE
}

main
