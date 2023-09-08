#!/bin/bash

alias kubectl="minikube kubectl --"

eval $(minikube docker-env)

kubectl apply -f mongo-deployment.yml && kubectl apply -f mongo-service.yml
kubectl apply -f pizzeria-pod.yml && kubectl apply -f pizzeria-deployment.yml && kubectl apply -f pizzeria-service.yml
kubectl apply -f proxy-pod.yml && kubectl apply -f proxy-deployment.yml && kubectl apply -f proxy-service.yml


minikube kubectl --delete service proxy-service pizzeria-service mongo-service 
minikube kubectl --delete deployment proxy-deployment pizzeria-deployment mongo-deployment 
minikube kubectl --delete pod proxy-pod pizzeria-pod mongo-pod 
