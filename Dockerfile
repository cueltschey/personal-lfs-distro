FROM alpine:3.19

RUN apk update && \
    apk add --no-cache gcc make g++ grep bash

CMD ["/bin/sh"]
