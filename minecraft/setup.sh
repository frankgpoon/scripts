#!/bin/bash

NAMESPACE="minecraft"

INSTALL_DIR="/home/$USER/.frankpoon"
UPDATE_SCRIPTS_DIR="$INSTALL_DIR/update_scripts"
RESOURCE_DIR="$INSTALL_DIR/resources"

MINECRAFT_VERSION="1.20.6"

main() {
  installDependencies
  setupEnv
  run
}

installDependencies() {
  echo "Installing dependencies..."

  wget -O - https://apt.corretto.aws/corretto.key | \
  sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | \
  sudo tee /etc/apt/sources.list.d/corretto.list

  sudo apt-get update
  sudo apt-get install -yqq java-21-amazon-corretto-jdk jq

  echo "🎉 Installed Java and jq"

  echo "✅ Done installing"
}

setupEnv() {
  echo "Setting up environment to run Minecraft"

  mkdir "$RESOURCE_DIR/$NAMESPACE"

  echo "$MINECRAFT_VERSION" > "$RESOURCE_DIR/$NAMESPACE/version"

  latest_build=$(curl -s https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds | \
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

  if [ "$latest_build" != "null" ]; then
      jar_name=paper-${MINECRAFT_VERSION}-${latest_build}.jar
      url="https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${latest_build}/downloads/${jar_name}"

      # Download the latest Paper version
      wget -O "$RESOURCE_DIR/$NAMESPACE/paper.jar" "$url"
      echo "🎉 Paper download completed"
  else
      echo "❌ Paper: No stable build for version $MINECRAFT_VERSION found :("
  fi
  
  source_dir="$(dirname "$0")/resources"
  cp "$source_dir/update.sh" "$UPDATE_SCRIPTS_DIR/$NAMESPACE.sh"

  cp "$source_dir/banned-ips.json" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/banned-players.json" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/eula.txt" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/ops.json" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/server.properties" "$RESOURCE_DIR/$NAMESPACE/"
  cp "$source_dir/whitelist.json" "$RESOURCE_DIR/$NAMESPACE/"

  echo "Enter a name for the world (leave blank for default \"world\"):"
  read -r world_name
  if [[ -z $world_name ]]; then
    world_name="world"
  fi
  echo "level-name=$world_name" >> "$RESOURCE_DIR/$NAMESPACE/server.properties"

  echo "Enter a seed for the world:"
  read -r seed
  if [[ -z $seed ]]; then
    seed="0"
  fi
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
        echo "java -Xmx$memory_size -Xms$memory_size \\"
        echo "--add-modules=jdk.incubator.vector -XX:+UseG1GC \\"
        echo "-XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \\"
        echo "-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \\"
        echo "-XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \\"
        echo "-XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \\"
        echo "-XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \\"
        echo "-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \\"
        echo "-Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true \\"
        echo "-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \\"
        echo "-XX:G1ReservePercent=20 -jar $RESOURCE_DIR/$NAMESPACE/paper.jar --nogui"
      } > "$RESOURCE_DIR/$NAMESPACE/start.sh"
      chmod +x "$RESOURCE_DIR/$NAMESPACE/start.sh"
      break
    else  
      echo "Memory value cannot be empty."
    fi
  done

  source_dir="$(dirname "$0")/resources"
  sudo cp "$source_dir/minecraft.service" /etc/systemd/system/
  sudo systemctl enable minecraft
  sudo systemctl start minecraft
}

main
