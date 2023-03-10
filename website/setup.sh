#!/bin/bash

SCRIPT_NAME="website"
WEBSITE_REPO_NAME="frankpoon"
WEBSITE_REPO_URL="git@github.com:frankgpoon/$WEBSITE_REPO_NAME.git"
FSB_REPO_NAME="fsb"
FSB_REPO_URL="git@github.com:frankgpoon/$FSB_REPO_NAME.git"

REPO_DIR="/home/$USER/repos"
WEBROOT_DIR="/home/$USER/webroot"

main() {
  setupStaticFiles
  installCaddy
  setupUpdates
}


setupStaticFiles() {
  mkdir "$REPO_DIR"
  mkdir "$WEBROOT_DIR"

  git clone $WEBSITE_REPO_URL "$REPO_DIR/$WEBSITE_REPO_NAME"
  git clone $FSB_REPO_URL "$REPO_DIR/$FSB_REPO_NAME"
  echo "🎉 Pulled website and Flashcard Study Buddy repos"
  
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/index.html" index.html
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/style.css" style.css
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/404.html" 404.html
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/resume/frank_poon_resume.pdf" resume.pdf

  mkdir "$WEBROOT_DIR/$FSB_REPO_NAME"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/fsb.html" fsb.html
  ln -s "$REPO_DIR/$FSB_REPO_NAME/resources/privacypolicy.pdf" privacypolicy.pdf
  echo "🎉 Finished creating symlinks"
  echo "✅ Finished loading static files"
}

installCaddy() {
  sudo apt-get install -yqq debian-keyring debian-archive-keyring apt-transport-https
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
  sudo apt-get -qq update
  sudo apt-get install -yqq caddy

  sudo caddy file-server --root "$WEBROOT_DIR"
}

setupUpdates() {
  install_dir="/home/$USER/.frankpoon"
  update_scripts_dir="$install_dir/update_scripts"
  source_dir="$(dirname "$0")/resources"
  cp "$source_dir/update.sh" "$update_scripts_dir/$SCRIPT_NAME.sh"
}