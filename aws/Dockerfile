FROM alpine/bombardier
ENV CONNECTIONS 1000
ENV INTERVAL 10m
COPY docker_entrypoint.sh ./
RUN apk --no-cache add curl && chmod +x docker_entrypoint.sh
ENTRYPOINT ["/docker_entrypoint.sh"]


