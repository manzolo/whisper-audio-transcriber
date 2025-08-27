FROM manzolo/openai-whisper-base:latest

WORKDIR /app

COPY ./entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

USER 1000:1000

ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]