#!/bin/bash

NAMESPACE="adobot"
REPO_URL="git@github.com:frankgpoon/$NAMESPACE.git"

INSTALL_DIR="/home/$USER/.frankpoon"
REPO_DIR="$INSTALL_DIR/repos"
UPDATE_SCRIPTS_DIR="$INSTALL_DIR/update_scripts"
RESOURCE_DIR="$INSTALL_DIR/resources"

main() {
  installDependencies
  setupEnv
  run
}

installDependencies() {
  echo "Installing dependencies..."

  # Setup Node LTS
  NODE_LTS_PPA="https://deb.nodesource.com/setup_lts.x"
  curl -sL $NODE_LTS_PPA | bash - > /dev/null 
  apt-get install -yqq nodejs npm
  echo "🎉 Installed Node.js and NPM"

  sudo npm i -g pm2
  echo "🎉 Installed pm2"

  echo "✅ Done installing"
}

setupEnv() {
  echo "Setting up environment to run Adobot"

  mkdir "$RESOURCE_DIR/$NAMESPACE"

  git clone "$REPO_URL" "$REPO_DIR/$NAMESPACE"
  echo "🎉 Pulled Adobot repo"

  source_dir="$(dirname "$0")/resources"
  cp "$source_dir/update.sh" "$UPDATE_SCRIPTS_DIR/$REPO_NAME.sh"

  while 0; do
    echo "Paste the Adobot discord token here"
    read -r discord_token
    if [[ -n $discord_token ]]; then
      echo "$discord_token" > "$RESOURCE_DIR/$NAMESPACE/discord_token"
      break
    else  
      echo "Token cannot be empty."
    fi
  done
  
  echo "✅ Done."
}

run() {
  envvars="ADOBOT_DISCORD_TOKEN=$(cat "$RESOURCE_DIR/$NAMESPACE/discord_token") ADOBOT_DEBUG_LEVEL=info"

  pm2 start --name "$NAMESPACE" "$envvars npm start"  -- prefix "$REPO_DIR/$NAMESPACE"
}

main
