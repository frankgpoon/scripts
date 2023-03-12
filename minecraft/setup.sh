#!/bin/bash

NAMESPACE="minecraft"

INSTALL_DIR="/home/$USER/.frankpoon"
UPDATE_SCRIPTS_DIR="$INSTALL_DIR/update_scripts"
RESOURCE_DIR="$INSTALL_DIR/resources"

main() {
  installDependencies
  setupEnv
  setupStartup
  run
}

installDependencies() {
  echo "Installing dependencies..."

  sudo apt-get install software-properties-common ca-certificates apt-transport-https curl

  curl https://apt.corretto.aws/corretto.key | sudo apt-key add -
  sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
  sudo apt-get update
  sudo apt-get install -y java-17-amazon-corretto-jdk
  echo "🎉 Installed Java"

  echo "✅ Done installing"
}

setupEnv() {
  echo "Setting up environment to run Minecraft"

  mkdir "$RESOURCE_DIR/$NAMESPACE"

  while true; do
    echo "Paste the link to the latest version of Paper server (https://papermc.io/downloads) here:"
    read -r url
    if [[ -n $url ]]; then
      wget -O "$RESOURCE_DIR/$NAMESPACE/paper.jar" "$url"
      break
    else  
      echo "Link cannot be empty."
    fi
  done
  
  source_dir="$(dirname "$0")/resources"
  cp "$source_dir/update.sh" "$UPDATE_SCRIPTS_DIR/$NAMESPACE.sh"

  cp "$source_dir/banned-ips.json" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/banned-players.json" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/eula.txt" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/ops.json" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/server.properties" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/whitelist.json" "$RESOURCE_DIR/$NAMESPACE/"

  echo "Enter a name for the world:"
  read -r world_name
  if [[ -z $world_name ]]; then
    world_name="world"
  fi
  echo "level-name=$world_name" >> "$RESOURCE_DIR/$NAMESPACE/server.properties"

  echo "Enter a seed for the world:"
  read -r seed
  echo "level-seed=$seed" >> "$RESOURCE_DIR/$NAMESPACE/server.properties"

  echo "Enter a MOTD for the server:"
  read -r motd
  if [[ -z $motd ]]; then
    motd="A Minecraft server"
  fi

  echo "motd=$motd" >> "$RESOURCE_DIR/$NAMESPACE/server.properties"

  echo "If you are using an existing world, copy the world to $RESOURCE_DIR/$NAMESPACE/."
  echo "Make sure the folder for the world is \"$world_name\"."
  echo "Press return to continue"
  read -r
  
  echo "✅ Done."
}

run() {
  while true; do
    echo "Enter how much memory to allocate to the server (e.g. \"256M\", \"4G\"):"  
    read -r memory_size
    if [[ -n $memory_size ]]; then
      {
        echo "#!/bin/bash"
        echo "java -Xmx$memory_size -Xms$memory_size -jar paper.jar --nogui"
      } > "$RESOURCE_DIR/$NAMESPACE/start.sh"
      break
    else  
      echo "Memory value cannot be empty."
    fi
  done

  source_dir="$(dirname "$0")/resources"
  sudo cp "$source_dir/paper.service" /etc/systemd/system/
  sudo systemctl enable paper
  sudo systemctl start paper
}

main
