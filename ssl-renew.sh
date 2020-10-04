#!/bin/bash

docker-compose -f PATH_TO_PROJECT_DIR/docker-compose.yml run --rm --no-deps certbot renew --dry-run && \
docker exec nginx nginx -s reload
