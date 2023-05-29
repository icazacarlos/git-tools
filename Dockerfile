FROM alpine:3.18.0
RUN apk update && \
  apk add --no-cache bash git tree
WORKDIR /app
COPY ./config/* ./config/
COPY ./script.sh .
RUN chmod +x /app/script.sh
ENTRYPOINT /app/script.sh
