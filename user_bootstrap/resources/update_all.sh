#!/bin/bash

install_dir="/home/$USER/.frankpoon"
update_scripts_dir="$install_dir/update_scripts"


successful_updates=0
for file in "$update_scripts_dir"/*.sh; do
  if bash "$file"; then
    echo "Successfully executed $file."
    successful_updates+=1
  else
    echo "Failed executing $file. Skipping."
  fi
done

echo "Ran $successful_updates scripts successfully."