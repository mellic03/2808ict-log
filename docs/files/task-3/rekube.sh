#!/bin/bash

# Create the pods, deployments and services for the containers

minikube kubectl -- apply -f mongo-dep.yml
minikube kubectl -- apply -f mongo-svc.yml

minikube kubectl -- apply -f pizzeria-pod.yml
minikube kubectl -- apply -f pizzeria-dep.yml
minikube kubectl -- apply -f pizzeria-svc.yml

minikube kubectl -- apply -f proxy-pod.yml
minikube kubectl -- apply -f proxy-dep.yml
minikube kubectl -- apply -f proxy-svc.yml