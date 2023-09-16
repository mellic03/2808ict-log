#!/bin/bash

# Create the pods, deployments and services for the containers

kubectl apply -f mongo-vol.yml && kubectl apply -f mongo-pvolc.yml
kubectl apply -f mongo-dep.yml && kubectl apply -f mongo-svc.yml

kubectl apply -f mongoexpress-dep.yml && kubectl apply -f mongoexpress-svc.yml

kubectl apply -f pizzeria-pod.yml && kubectl apply -f pizzeria-dep.yml && kubectl apply -f pizzeria-svc.yml

kubectl apply -f proxy-pod.yml && kubectl apply -f proxy-dep.yml && kubectl apply -f proxy-svc.yml