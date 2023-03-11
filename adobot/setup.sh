#!/bin/bash

REPO_NAME="adobot"
REPO_URL="git@github.com:frankgpoon/$REPO_NAME.git"

INSTALL_DIR="/home/$USER/.frankpoon"
REPO_DIR="/$INSTALL_DIR/repos"
UPDATE_SCRIPTS_DIR="$INSTALL_DIR/update_scripts"


main() {
  setupEnv
  setupUpdates
  runAdobot
}

setupEnv() {
  echo "Setting up environment to run Adobot"
  sudo npm i -g pm2
  echo "🎉 Installed pm2"

  git clone "$REPO_URL" "$REPO_DIR/$REPO_NAME"
  echo "🎉 Pulled Adobot repo"
  
  echo "✅ Finished loading static files"
}


setupUpdates() {
  source_dir="$(dirname "$0")/resources"
  cp "$source_dir/update.sh" "$UPDATE_SCRIPTS_DIR/$REPO_NAME.sh"
}

runAdobot() {
  pm2 start npm --name "$REPO_NAME" -- start
}

main
