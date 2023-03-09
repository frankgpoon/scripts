#!/bin/bash

main() {
  

  echo "Welcome to Frank's bootstrap script!"
  echo "---------------------------------------------"

  installDependencies
  setupUserAccount $USERNAME
  addClientSshKey $USERNAME
  createGithubSshKey $USERNAME
  setupUpdater $USERNAME
}

installDependencies() {
  echo "Installing dependencies..."

  # Setup git
  apt install -yq git
  echo "🎉 Installed git"

  # Setup Python 3
  apt install -yq python3 python3-pip

  echo "🎉 Installed Python and Pip"

  # Setup Node LTS https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh
  NODE_LTS_PPA="https://deb.nodesource.com/setup_lts.x"
  curl -sL $NODE_LTS_PPA | bash - && apt install -yq nodejs npm

  echo "🎉 Installed Node.js and NPM"

  apt install -yq neovim  

  # Final update/upgrade
  apt update
  apt upgrade -yq

  echo "✅ Done installing"
}


setupUserAccount() {
  username=$1
  echo "Setting up account for $username..."
  useradd -m "$username"
  mkdir "/home/$username/.ssh"
  echo "🎉 Created user $username"

  while true; do
    
    if passwd "$username"; then
      echo "🎉 Added password for $username"
      break
    else
      echo "❌ Password was not successfully changed"
    fi
  done

  adduser "$username" sudo
  echo "🎉 Added sudo privilege for $username"
  echo "✅ User was successfully created"
}


addClientSshKey() {
  echo "If you want to add a client SSH key for this host, you can paste it here."
  echo "Otherwise, a key will not be added."
  read -r client_key

  if [[ -n $client_key ]]; then
    authorized_keys_path="/home/$username/.ssh/authorized_keys"

    {
      echo "# Client SSH key"
      echo "$client_key"
      echo
    } >> "$authorized_keys_path"

    echo "✅ Added client key to authorized keys"
  else
    echo "⚠️ Adding client key skipped"
  fi
}


createGithubSshKey() {
  echo "Setting up Github SSH key..."

  username=$1

  KEY_FILENAME="github"

  ssh_path="/home/$username/.ssh/"
  private_key_path="$ssh_path/$KEY_FILENAME"
  public_key_path="$ssh_path/$KEY_FILENAME.pub"
  config_path="$ssh_path/config"

  ssh-keygen -t ed25519 -C "$KEY_FILENAME" -P "" -f "$private_key_path"
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

setupUpdater() {
  username=$1

  echo "Setting up auto-update directory and infrastructure for $username..."
  install_dir="/home/$username/.frankpoon"
  update_scripts_dir="$install_dir/update_scripts"
  source_dir=${0%/*}

  mkdir "$update_scripts_dir"
  cp "$source_dir/update_all.sh" "$install_dir"
  echo "🎉 Created directories. You can put new update scripts under ~/.frankpoon/update_scripts."

  (crontab -lu "$username"; echo "0 0 * * 0 $install_dir/update_all.sh") | sort -u | crontab -u "$username" -
}

USERNAME="frank"

main $USERNAME