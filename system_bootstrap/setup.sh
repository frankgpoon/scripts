#!/bin/bash

main() {
  echo "Welcome to Frank's system bootstrap script!"
  echo "This script should be ran as root."

  installDependencies
  setupUserAccount
}

installDependencies() {
  echo "Installing dependencies..."

  # Setup git
  apt-get install -yqq git
  echo "🎉 Installed git"

  echo "✅ Done installing"
}

setupUserAccount() {
  echo "Enter the name of the user that you want to create:"
  read -r username
  useradd -m "$username"
  echo "🎉 Created user $username"

  while true; do
    if passwd "$username"; then
      echo "🎉 Added password for $username"
      break
    else
      echo "❌ Password was not successfully changed"
    fi
  done

  echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/dont-prompt-$username-for-sudo-password"

  echo "🎉 Added sudo privilege for $username with NOPASSWD bypass"
  
  source_dir=$(dirname "$(dirname "$(realpath "$0")")")
  dest_dir="/home/$username/"
  cp -R "$source_dir" "$dest_dir"
  chown -R "$username" "$dest_dir/$(basename "$source_dir")"


  echo "✅ User was successfully created"

  echo "This script is now finished. You should now login as $username"
  echo "and continue setup via ~/$(basename "$source_dir")."
}

main
