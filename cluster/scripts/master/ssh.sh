#!/usr/bin/env bash

echo "---SSH configuration---"

SRC_PATH="/vagrant/conf/keys"
PRIV_FILENAME="id_rsa"
DEST_PATH="/home/vagrant/.ssh"
PUB_FILENAME="id_rsa.pub"

# Function to concatenate two paths
join_path() {
  local IFS="/"
  echo "$*"
}

# Check if the public key exists
if ! [ -e "$(join_path $DEST_PATH $PUB_FILENAME)" ]; then
  echo "Copying SSH keys to $DEST_PATH"
  cp "$(join_path $SRC_PATH $PUB_FILENAME)" $DEST_PATH  # Copy the public key
  cp "$(join_path $SRC_PATH $PRIV_FILENAME)" $DEST_PATH # Copy the private key

  # Add the public key to the authorized keys
  cat "$(join_path $SRC_PATH $PUB_FILENAME)" >>"$(join_path $DEST_PATH 'authorized_keys')"
else
  echo "SSH keys already exist"
fi
