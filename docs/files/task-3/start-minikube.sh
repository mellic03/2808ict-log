#!/bin/bash

# Create an alias for kubectl, start minikube and configure
# environment variables for using docker inside minikube.

alias kubectl="minikube kubectl --"
minikube start
eval $(minikube docker-env)
