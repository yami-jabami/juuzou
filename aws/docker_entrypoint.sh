#!/bin/sh
curl --output resources_all.txt -fsSL $RESOURCES_URL
resource=$(shuf -n 1 resources_all.txt)
bombardier -c ${CONNECTIONS} -s -d ${INTERVAL} --http1 -t 1s -o json -p r -l $resource