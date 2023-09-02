#!/bin/bash

# Run all containers.
# The mongodb backend has to be run first, as both mongoexpress and nginx will look for it.
# The frontend also has to be run before nginx, as nginx will look for it.

docker run --network=bridge-net --name=mongo-backend -p 27017:27017 -d mongo
docker run --network=bridge-net --name=mongoexpress  -p 8081:8081 -d mongo-express -e ME_CONFIG_MONGODB_SERVER=mongo-backend
docker run --network=bridge-net --name=node-frontend -p 4200:4200 -d pizzeria
docker run --network=bridge-net --name=nginx-proxy   -p 80:80 -p 443:443  -d proxy



