#!/bin/bash

NAMESPACE="website"

INSTALL_DIR="/home/$USER/.frankpoon"
REPO_DIR="$INSTALL_DIR/repos"
UPDATE_SCRIPTS_DIR="$INSTALL_DIR/update_scripts"
RESOURCE_DIR="$INSTALL_DIR/resources"

WEBSITE_REPO_NAME="frankpoon"
WEBSITE_REPO_URL="git@github.com:frankgpoon/$WEBSITE_REPO_NAME.git"
FSB_REPO_NAME="fsb"
FSB_REPO_URL="git@github.com:frankgpoon/$FSB_REPO_NAME.git"

main() {
  installDependencies
  setupEnv
  setupStaticFiles
  runCaddy
}

installDependencies() {
  echo "Installing dependencies..."

  sudo apt-get install -yqq debian-keyring debian-archive-keyring apt-transport-https
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
  sudo apt-get -qq update
  sudo apt-get install -yqq caddy

  echo "✅ Done installing"
}

setupEnv() {
  echo "Setting up environment..."
  mkdir "$RESOURCE_DIR/$NAMESPACE"

  source_dir="$(dirname "$0")/resources"
  cp "$source_dir/Caddyfile" "$RESOURCE_DIR/$NAMESPACE"
  cp "$source_dir/update.sh" "$UPDATE_SCRIPTS_DIR/$NAMESPACE.sh"
  echo "✅ Done."
}

setupStaticFiles() {
  echo "Setting up static files"
  webroot_dir="$RESOURCE_DIR/$NAMESPACE/webroot"

  git clone $WEBSITE_REPO_URL "$REPO_DIR/$WEBSITE_REPO_NAME"
  git clone $FSB_REPO_URL "$REPO_DIR/$FSB_REPO_NAME"
  echo "🎉 Pulled website and Flashcard Study Buddy repos"
  
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/index.html" "$webroot_dir/index.html"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/style.css" "$webroot_dir/style.css"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/404.html" "$webroot_dir/404.html"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/resume/frank_poon_resume.pdf" "$webroot_dir/resume.pdf"

  mkdir "$WEBROOT_DIR/$FSB_REPO_NAME"
  ln -s "$REPO_DIR/$WEBSITE_REPO_NAME/www/fsb.html" "$webroot_dir/fsb.html"
  ln -s "$REPO_DIR/$FSB_REPO_NAME/resources/privacypolicy.pdf" "$webroot_dir/privacypolicy.pdf"
  echo "🎉 Finished creating symlinks"
  echo "✅ Finished loading static files"
}

runCaddy() {
  sudo setcap CAP_NET_BIND_SERVICE=+eip "$(which caddy)"
  caddy start --config "$CONFIG_DIR/Caddyfile"
}

main
