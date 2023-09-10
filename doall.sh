#!/bin/bash

alias kubectl="minikube kubectl --"

eval $(minikube docker-env)

kubectl apply -f mongo.yml
kubectl apply -f pizzeria.yml
kubectl apply -f proxy.yml

kubectl apply -f mongo-dep.yml && kubectl apply -f mongo-svc.yml
kubectl apply -f pizzeria-pod.yml && kubectl apply -f pizzeria-dep.yml && kubectl apply -f pizzeria-svc.yml
kubectl apply -f proxy-pod.yml && kubectl apply -f proxy-dep.yml && kubectl apply -f proxy-svc.yml

