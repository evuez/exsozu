FROM clevercloud/sozu:latest

RUN apk add --no-cache \
  libgcc \
  python3

COPY start.sh /start.sh
COPY config.toml /config.toml

RUN mkdir /data
RUN mkdir /run/sozu

EXPOSE 8080

CMD ["/start.sh"]
