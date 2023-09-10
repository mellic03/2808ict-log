#!/bin/bash

docker stop proxy
docker rm proxy
docker rmi -f nginx-proxy
docker build -t nginx-proxy .
docker run --network=bridge-net --name=proxy -p 80:80 -p 443:443 -d nginx-proxy
