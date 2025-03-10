#!/bin/bash

set -e

#Important: Run with chmod +x script.sh and execute as ./script.sh. May prompt for sudo password.

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check and install Docker
if command_exists docker; then
  echo "Docker is already installed."
else
  echo "Docker not found, installing..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker installed. Please restart your shell or logout/login."
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask docker
    echo "Docker installed. Please open Docker.app manually to finish setup."
  fi
fi

# Check and install make
if command_exists make; then
  echo "make is already installed."
else
  echo "make not found, installing..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update && sudo apt-get install -y build-essential
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install make
  fi
fi

# Add hosts file entry (requires sudo)
HOST_ENTRY="127.0.0.1 rag.local"
if ! grep -qF "$HOST_ENTRY" /etc/hosts; then
  echo "Adding '$HOST_ENTRY' to /etc/hosts..."
  echo "$HOST_ENTRY" | sudo tee -a /etc/hosts
else
  echo "Host entry already exists."
fi

echo "✅ All done."
