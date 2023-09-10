#!/bin/bash

# Deletes all services, deployments and pods created by rekube.sh

minikube kubectl -- delete service proxy-service pizzeria-service mongo-service
minikube kubectl -- delete deployment proxy-deployment pizzeria-deployment mongo-deployment
minikube kubectl -- delete pod proxy-pod pizzeria-pod mongo-pod