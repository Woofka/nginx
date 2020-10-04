#!/bin/bash

/usr/local/bin/docker-compose -f PATH_TO_PROJECT_DIR/docker-compose.yml run certbot renew --dry-run \
&& /usr/local/bin/docker-compose -f PATH_TO_PROJECT_DIR/docker-compose.yml kill -s SIGHUP nginx