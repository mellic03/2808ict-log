#!/bin/bash

# Deletes all services, deployments and pods created by rekube.sh

minikube kubectl -- delete service proxy-service pizzeria-service mongo-service mongoexpress-service
minikube kubectl -- delete deployment proxy-deployment pizzeria-deployment mongo-deployment mongoexpress-deployment
minikube kubectl -- delete pod proxy-pod pizzeria-pod
