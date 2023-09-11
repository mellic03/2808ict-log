#!/bin/bash

# Stop and remove the pizzeria container and image, rebuild the image and start the container again.
# Place and run from parent directory of pizzeria project

docker stop node-frontend
docker rm node-frontend
docker rmi -f pizzera
docker build -t pizzeria .
docker run --network=chat-net --name=node-frontend -p 4200:4200 -d pizzeria
