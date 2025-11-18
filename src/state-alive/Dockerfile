FROM alpine:latest

RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh
COPY flag_part1.txt /flag_part1.txt

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]