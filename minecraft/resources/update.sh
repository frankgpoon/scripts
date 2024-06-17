#!/bin/bash
NAMESPACE="minecraft"
INSTALL_DIR="/home/$USER/.frankpoon"
RESOURCE_DIR="$INSTALL_DIR/resources"

MINECRAFT_VERSION=$(cat "$RESOURCE_DIR/$NAMESPACE/version")

main() {
  sudo systemctl stop minecraft

  latest_build=$(curl -s https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds | \
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

  if [ "$latest_build" != "null" ]; then
      jar_name=paper-${MINECRAFT_VERSION}-${latest_build}.jar
      url="https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${latest_build}/downloads/${jar_name}"

      # Download the latest Paper version
      wget -O "$RESOURCE_DIR/$NAMESPACE/paper.jar" "$url"
      echo "🎉 Paper update completed"
  else
      echo "❌ Paper: No stable build for version $MINECRAFT_VERSION found :("
  fi
  
  sudo systemctl start minecraft
}