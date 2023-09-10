#!/bin/bash

# Docker attach doesn't work so use this instead.
# ./attach <container name>

docker exec -it $1 bash
