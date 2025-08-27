#!/bin/bash

set -euo pipefail

# Configuration
AUDIO_FOLDER="${AUDIO_FOLDER:-/audio-files/temp/}"
AAC_EXTENSIONS=("aac" "m4a" "adts")
MP3_EXTENSION="mp3"
WHISPER_MODEL="${WHISPER_MODEL:-large}"
WHISPER_LANGUAGE="${WHISPER_LANGUAGE:-Italian}"
MODEL_DIR="${MODEL_DIR:-/models}"

# Check if directories exist
if [ ! -d "$AUDIO_FOLDER" ]; then
  echo "Error: Directory $AUDIO_FOLDER does not exist!"
  exit 1
fi
if [ ! -d "$MODEL_DIR" ]; then
  echo "Error: Model directory $MODEL_DIR does not exist!"
  exit 1
fi

# Check if ffmpeg and whisper are available
command -v ffmpeg >/dev/null 2>&1 || { echo "Error: ffmpeg not found!"; exit 1; }
command -v whisper >/dev/null 2>&1 || { echo "Error: whisper not found!"; exit 1; }

echo "Starting processing..."

# Function to convert audio files to MP3
convert_audio_to_mp3() {
  local audio_file="$1"
  local filename_no_ext="${audio_file%.*}"
  local output_file="$filename_no_ext.$MP3_EXTENSION"

  if [ -f "$output_file" ]; then
    echo "File $output_file already exists, skipping conversion."
    return
  fi

  echo "Converting: $audio_file -> $output_file"
  if ffmpeg -i "$audio_file" -acodec libmp3lame -ab 192k "$output_file" 2>/dev/null; then
    chown "$(id -u):$(id -g)" "$output_file"
    rm "$audio_file"
    echo "Conversion completed: $audio_file"
  else
    echo "Error during conversion of $audio_file"
    exit 1
  fi
}

# Function to process MP3 files with Whisper
process_mp3_with_whisper() {
  local audio_file="$1"
  local audio_file_name=$(basename -- "$audio_file" ."$MP3_EXTENSION")
  local txt_file="$AUDIO_FOLDER/$audio_file_name.txt"
  local log_file="$AUDIO_FOLDER/$audio_file_name.log"

  if [ -f "$txt_file" ]; then
    echo "$audio_file_name.txt exists, skipping..."
    return
  fi

  echo "Processing $audio_file_name.$MP3_EXTENSION with Whisper"
  if whisper "$audio_file" --device cuda --model_dir "$MODEL_DIR" --model "$WHISPER_MODEL" \
    --language "$WHISPER_LANGUAGE" --output_dir "$AUDIO_FOLDER" --output_format txt > "$log_file" 2>&1; then
    # Replace newlines with spaces
    tr '\n' ' ' < "$txt_file" > "${txt_file}.tmp" && mv "${txt_file}.tmp" "$txt_file"
    chown "$(id -u):$(id -g)" "$txt_file"
    echo "Processing completed: $audio_file_name"
  else
    echo "Error during processing of $audio_file_name (see $log_file)"
    exit 1
  fi
}

# Display Whisper help
echo "Whisper help:"
echo "-------------------------------------"
whisper --help
echo "-------------------------------------"

# Convert audio files
echo "Converting audio files..."
for ext in "${AAC_EXTENSIONS[@]}"; do
  shopt -s nullglob
  for audio_file in "$AUDIO_FOLDER"*."$ext"; do
    if [ -f "$audio_file" ]; then
      convert_audio_to_mp3 "$audio_file"
    fi
  done
done

# Process MP3 files
echo "Processing MP3 files..."
shopt -s nullglob
for mp3_file in "$AUDIO_FOLDER"*."$MP3_EXTENSION"; do
  if [ -f "$mp3_file" ]; then
    process_mp3_with_whisper "$mp3_file"
  else
    echo "$AUDIO_FOLDER: No MP3 files found!"
  fi
done

echo "Processing completed."