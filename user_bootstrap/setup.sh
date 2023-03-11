#!/bin/bash

INSTALL_DIR="/home/$USER/.frankpoon"
REPO_DIR="$INSTALL_DIR/repos"
UPDATE_SCRIPTS_DIR="$INSTALL_DIR/update_scripts"
RESOURCE_DIR="$INSTALL_DIR/resources"

SSH_DIR="/home/$USER/.ssh"


main() {

  echo "Welcome to Frank's user bootstrap script!"
  echo "---------------------------------------------"

  setupEnv
  addClientSshKey
  createGithubSshKey
  setupUpdater
}

setupClientSshKey() {
  echo "If you want to add a client SSH key for this host, you can paste it here."
  echo "Otherwise, a key will not be added."
  read -r client_key

  if [[ -n $client_key ]]; then
    authorized_keys_path="$SSH_DIR/authorized_keys"

    {
      echo "# Client SSH key"
      echo "$client_key"
      echo
    } >> "$authorized_keys_path"

    echo "✅ Added client key to authorized keys"
    echo -e "Add the following lines to ~/.ssh/config:\n"
    echo "Host $(hostname -I | awk '{print $1}')"
    echo "  Preferredauthentications publickey"
    echo "  IdentityFile <path to your client ssh key>"
    echo
  else
    echo "⚠️ Adding client key skipped"
  fi
}

createGithubSshKey() {
  echo "Setting up Github SSH key..."

  KEY_FILENAME="github"

  private_key_path="$SSH_DIR/$KEY_FILENAME"
  public_key_path="$SSH_DIR/$KEY_FILENAME.pub"
  config_path="$SSH_DIR/config"

  ssh-keygen -q -t ed25519 -C "$KEY_FILENAME" -P "" -f "$private_key_path"
  {
    echo "# Github SSH key"
    echo "Host github.com"
    echo "  Preferredauthentications publickey"
    echo "  IdentityFile ~/.ssh/$KEY_FILENAME"
    echo
  } >> "$config_path"

  echo "✅ Done. Please add the following SSH key into Github:"
  echo -e "\n$(cat "$public_key_path")\n"
}

setupEnv() {

  echo "Setting up environment for $USER..."
  mkdir "$INSTALL_DIR"
  mkdir "$UPDATE_SCRIPTS_DIR"
  mkdir "$REPO_DIR"
  mkdir "$RESOURCE_DIR"

  mkdir "$SSH_DIR"

  echo "✅ Finished setting up environment for $USER."
}

setupUpdater() {
  echo "Setting up auto-update directory and infrastructure for $USER..."
  
  source_dir="$(dirname "$0")/resources"
  
  cp "$source_dir/update_all.sh" "$INSTALL_DIR"
  echo "✅ Created directories. You can put new update scripts under $UPDATE_SCRIPTS_DIR."

  (crontab -lu; echo "0 0 * * 0 $INSTALL_DIR/update_all.sh") | sort -u | crontab -
}

main
