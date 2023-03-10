#!/bin/bash

SCRIPT_NAME="website"
WEBSITE_REPO_NAME="frankpoon"
WEBSITE_REPO_URL="git@github.com:frankgpoon/$WEBSITE_REPO_NAME.git"
FSB_REPO_NAME="fsb"
FSB_REPO_URL="git@github.com:frankgpoon/$FSB_REPO_NAME.git"

INSTALL_DIR="/home/$USER/.frankpoon"
REPO_DIR="/$INSTALL_DIR/repos"
UPDATE_SCRIPTS_DIR="$INSTALL_DIR/update_scripts"
CONFIG_DIR="$INSTALL_DIR/config"

WEBROOT_DIR="$INSTALL_DIR/webroot"

main() {
  setupStaticFiles
  setupUpdates
  installCaddy
}


setupStaticFiles() {
  mkdir "$WEBROOT_DIR"

  git clone $WEBSITE_REPO_URL "$REPO_DIR/$WEBSITE_REPO_NAME"
  git clone $FSB_REPO_URL "$REPO_DIR/$FSB_REPO_NAME"
  echo "🎉 Pulled website and Flashcard Study Buddy repos"
  
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/index.html" "$WEBROOT_DIR/index.html"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/style.css" "$WEBROOT_DIR/style.css"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/404.html" "$WEBROOT_DIR/404.html"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/resume/frank_poon_resume.pdf" "$WEBROOT_DIR/resume.pdf"

  mkdir "$WEBROOT_DIR/$FSB_REPO_NAME"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/fsb.html" "$WEBROOT_DIR/fsb.html"
  ln -s "$REPO_DIR/$FSB_REPO_NAME/resources/privacypolicy.pdf" "$WEBROOT_DIR/privacypolicy.pdf"
  echo "🎉 Finished creating symlinks"
  echo "✅ Finished loading static files"
}

installCaddy() {
  sudo apt-get install -yqq debian-keyring debian-archive-keyring apt-transport-https
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
  sudo apt-get -qq update
  sudo apt-get install -yqq caddy

  sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/caddy
  caddy run --config "$CONFIG_DIR/Caddyfile"
}

setupUpdates() {
  source_dir="$(dirname "$0")/resources"
  cp "$source_dir/update.sh" "$UPDATE_SCRIPTS_DIR/$SCRIPT_NAME.sh"
  cp "$source_dir/Caddyfile" "$CONFIG_DIR/"
}

main
