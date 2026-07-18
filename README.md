# Whisper Audio Transcriber

This project automates the conversion of audio files (AAC, M4A, ADTS) to MP3 and their transcription to text using OpenAI Whisper with GPU acceleration. It builds upon the `manzolo/openai-whisper-docker` repository to create a base image (`manzolo/openai-whisper-base:latest`) and extends it for batch processing.

## Prerequisites

- Docker installed with NVIDIA Container Toolkit for GPU support.
- Git installed to clone repositories.
- NVIDIA GPU compatible with CUDA.
- Local directories for models (`./models`) and audio files (`./audio-files/temp`).

## Installation

1. **Clone this repository**:
   ```bash
   git clone https://github.com/manzolo/whisper-audio-transcriber.git
   cd whisper-audio-transcriber
   ```

2. **Create an optional `.env` file**:
   ```env
   PUID=1000
   PGID=1000
   WHISPER_MODEL=base
   WHISPER_LANGUAGE=Italian
   MODEL_DIR=/models
   AUDIO_FOLDER=/audio-files/temp/
   ```

3. **Build the Docker images**:
   Run the `build.sh` script to clone `manzolo/openai-whisper-docker` and build the base and final images:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

4. **Run the container**:
   Use Docker Compose to start the container:
   ```bash
   docker compose up
   ```

## Configuration

- **Environment Variables**:
  - `PUID`/`PGID`: User and group IDs for permissions (default: 1000).
  - `WHISPER_MODEL`: Whisper model to use (e.g., `large`, `turbo`) (default: `large`).
  - `WHISPER_LANGUAGE`: Transcription language (default: `Italian`).
  - `MODEL_DIR`: Model directory (default: `/models`).
  - `AUDIO_FOLDER`: Audio file directory (default: `/audio-files/temp/`).

- **Volumes**:
  - `./models:/models`: Local directory for Whisper models.
  - `./audio-files:/audio-files`: Local directory for audio files.

## Usage

1. Place audio files (AAC, M4A, ADTS, MP3) in `./audio-files/temp`.
2. The container automatically converts files to MP3 and generates text transcriptions (`.txt`) in the same directory.
3. Processing logs are saved as `.log` files in the audio directory.

## Notes

- The base image `manzolo/openai-whisper-base:latest` is built from `https://github.com/manzolo/openai-whisper-docker`.
- For GPUs with limited VRAM (e.g., 8 GB), consider using the `turbo` model by setting `WHISPER_MODEL=turbo`.
- To verify GPU support, run:
  ```bash
  docker run --rm --gpus all -it manzolo/openai-whisper-base:latest nvidia-smi
  ```

## References

- [OpenAI Whisper](https://github.com/openai/whisper)
- [manzolo/openai-whisper-docker](https://github.com/manzolo/openai-whisper-docker)
- [Docker Documentation](https://docs.docker.com)

## License

This project is licensed under the MIT License.

---

## 🧠 Local AI Lab

This project is part of **[manzolo's Local AI Lab](https://github.com/manzolo/local-ai-lab)** — a family of self-hosted AI projects (LLM, voice, vision & documents) that share the same conventions and can be wired together through the shared `local-ai-net` Docker network.

Explore the whole family: [`topic:local-ai`](https://github.com/search?q=user%3Amanzolo+topic%3Alocal-ai&type=repositories)
