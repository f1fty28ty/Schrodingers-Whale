FROM alpine:latest

RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh
COPY flag_part2.txt /flag_part2.txt

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]