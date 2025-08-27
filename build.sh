#!/bin/bash

set -euo pipefail

# Configuration
BASE_IMAGE="manzolo/openai-whisper-base:latest"
FINAL_IMAGE="manzolo/openai-whisper"
REPO_URL="https://github.com/manzolo/openai-whisper-docker.git"
TEMP_DIR="./temp_openai_whisper_docker"

# Function to clone the repository
clone_repo() {
  if [ -d "$TEMP_DIR" ]; then
    echo "Repository already cloned in $TEMP_DIR, updating..."
    cd "$TEMP_DIR"
    git pull origin main || { echo "Error updating repository"; exit 1; }
    cd - > /dev/null
  else
    echo "Cloning repository $REPO_URL into $TEMP_DIR..."
    git clone "$REPO_URL" "$TEMP_DIR" || { echo "Error cloning repository"; exit 1; }
  fi
}

# Function to build the base image
build_base_image() {
  echo "Building base image: $BASE_IMAGE"
  cd "$TEMP_DIR"
  if ! docker build -t "$BASE_IMAGE" .; then
    echo "Error building $BASE_IMAGE"
    exit 1
  fi
  cd - > /dev/null
}

# Function to build the final image
build_final_image() {
  echo "Building final image: $FINAL_IMAGE"
  if ! docker build -t "$FINAL_IMAGE" .; then
    echo "Error building $FINAL_IMAGE"
    exit 1
  fi
}

# Execution
clone_repo
build_base_image
build_final_image

rm -rf $TEMP_DIR

echo "Build completed successfully!"