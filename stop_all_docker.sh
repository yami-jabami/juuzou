#!/bin/bash

docker stop $(docker ps -a -q --filter ancestor=alpine/bombardier --format="{{.ID}}")

echo "All docker container stopped."
