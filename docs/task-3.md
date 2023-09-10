# Task 3 - Minikube and Kubectl

- Ensure instance has at least 2 CPU cores.
    - Stop the instance
    - Go to actions > instance settings > change instance type
    - Select t2.medium
    - Start the instance

## Install Minikube
- Install Minikube. \
    `$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64` \
    `$ sudo install minikube-linux-amd64 /usr/local/bin/minikube`

- Create alias for kubectl. \
    `$ alias kubectl="minikube kubectl --"`

- Deleted downloaded file after install. \
    `$ rm -R minikube-linux-amd64`

- Start Minikube. \
    `$ minikube start` \
    `$ minikube status`

- List pods running in the cluster. \
    `$ kubectl get pods -A`

## Minikube + Docker
- Configure the local environment variables to run docker inside the Minikube container. \
    `$ eval $(minikube docker-env)`

- List the docker images. \
    `$ docker images`
    ![](img/task%203/docker-images-0.png)

## Pizzeria (frontend)

- Make a new directory called `task3` and copy the pizzeria app into it. \
  `$ mkdir task3` \
  `$ cp task1/pizzeria task3/pizzeria`

- Navigate to the pizzeria project directory and build the frontend docker image from task 1. \
    `$ cd task3/pizzeria` \
    `$ docker build -t frontend .`

#### Create a deployment for MongoDB
- Create a mongo-deployment.yml file. \
  `$ nano mongo-deployment.yml`

      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: mongo-deployment
        labels:
          app: mongo
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: mongo
        template:
          metadata:
            labels:
              app: mongo
          spec:
            containers:
            - name: backend
              image: mongo
              ports:
              - containerPort: 27017

- Apply the deployment. \
  `$ kubectl apply -f mongo-deployment.yml`


#### Create a service for MongoDB
- Create a mongo-service.yml file. \
  `$ nano mongo-service.yml`

      apiVersion: v1
      kind: Service
      metadata:
        name: mongo-service
      spec:
        selector:
          app: mongo
        ports:
          - protocol: TCP
            port: 27017
            targetPort: 27017

- Apply the service. \
  `$ kubectl apply -f mongo-service.yml`

#### Create a pod for the Pizzeria app
Like in task 1, the pizzeria app requires some environment variables to be defined.
- Go back to the parent directory and create a pizzeria-pod.yml file. \
    `$ cd ..` \
    `$ nano pizzeria-pod.yml`

      apiVersion: v1
      kind: Pod
      metadata:
        name: pizzeria-pod
        labels:
          app: pizzeria
      spec:
        containers:
          - name: frontend
            imagePullPolicy: Never
            image: pizzeria
            env:
            - name: MONGODB_URI
              value: "mongodb://backend:27017/"
            - name: PORT
              value: "4200"
            - name: SECRET
              value: "secret"

- Create the pod. \
  `$ kubectl apply -f pizzeria-pod.yml`

- Verify the pod status. \
  `$ kubectl get pods` \
  ![](img/task%203/pod-status.png)

- Check logs to ensure nothing went wrong. \
  `$ kubectl logs pizzeria-pod` \
  ![](img/task%203/pod-logs.png)

#### Create a deployment for the Pizzeria app

- Create a pizzeria-deployment.yml file. \
  `$ nano pizzeria-deployment.yml`

      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: pizzeria-deployment
        labels:
          app: pizzeria
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: pizzeria
        template:
          metadata:
            labels:
              app: pizzeria
          spec:
            containers:
            - name: frontend
              image: pizzeria
              imagePullPolicy: Never
              ports:
              - containerPort: 4200

- Run the deployment. \
  `$ kubectl apply -f pizzeria-deployment.yml`

#### Create a service for the Pizzeria app
- Create a pizzeria-service.yml file. \
  `$ nano pizzeria-service.yml`

      apiVersion: v1
      kind: Service
      metadata:
        name: pizzeria-service
      spec:
        type: LoadBalancer
        selector:
          app: pizzeria
        ports:
          - protocol: TCP
            port: 4200
            targetPort: 4200
            nodePort: 32000


- Apply the service. \
  `$ kubectl apply -f pizzeria-service.yml`


#### Create a pod for the nginx proxy
- Copy the nginx-proxy from task 1 to the `task3` directory. \
  `$ cp task1/nginx-proxy task3/nginx-proxy`

- Create a proxy-pod.yml file. \
  `$ nano proxy-pod.yml`

      apiVersion: v1
      kind: Pod
      metadata:
        name: proxy-pod
        labels:
          app: proxy
      spec:
        containers:
          - name: proxy
            imagePullPolicy: Never
            image: nginx-proxy

- Apply the pod. \
  `$ kubectl apply -f proxy-pod.yml`

#### Create a deployment for the nginx proxy
- Create a proxy-deployment.yml file. \
  `$ nano proxy-deployment.yml`

      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: proxy-deployment
        labels:
          app: proxy
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: proxy
        template:
          metadata:
            labels:
              app: proxy
          spec:
            containers:
            - name: proxy
              image: nginx-proxy
              imagePullPolicy: Never
              ports:
              - containerPort: 80

- Apply the deployment. \
  `$ kubectl apply -f proxy-deployment.yml`

#### Create a service for the nginx proxy
- Create a proxy-service.yml file. \
  `$ nano proxy-service.yml`

      apiVersion: v1
      kind: Service
      metadata:
        name: proxy-service
      spec:
        type: LoadBalancer
        selector:
          app: proxy
        ports:
          - protocol: TCP
            port: 80
            targetPort: 443
            nodePort: 32001

- Apply the service. \
  `$ kubectl apply -f proxy-service.yml`


#### Expose the App

- Expose the Nginx server to the internet. \
  `$ kubectl port-forward svc/proxy-service 8080:443 --address 0.0.0.0 &`
  - `svc/proxy-service` -The Service to run, in our case the nginx proxy.
  - `8080:443` -Forward the external port 8080 to internal port 443 (HTTPS). The external port is the one used to connect to the service over the internet.
  - `--address 0.0.0.0` -Specify which IP address to allow connections from. `0.0.0.0` will allow connections from any IP address.
  - `&` - An ampersand tells Linux to run the process in the background, leaving the shell available to use.
