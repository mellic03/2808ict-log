#!/bin/bash

# Stop and remove all containers (not images)

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# docker rmi -f proxy
# docker rmi -f mongo
# docker rmi -f mongo-express
