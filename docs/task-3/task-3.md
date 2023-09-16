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
    ![](img/docker-images-0.png)

## Pizzeria (frontend)

- Make a new directory called `task3` and copy the pizzeria app into it. \
  `$ mkdir task3` \
  `$ cp task1/pizzeria task3/pizzeria`

- Navigate to the pizzeria project directory and build the frontend docker image from task 1. \
    `$ cd task3/pizzeria` \
    `$ docker build -t frontend .`

## Minikube
#### Create a persistent volume

- Create a mongo-pvol.yml file. \
  `$ nano mongo-pvol.yml`

      apiVersion: v1
      kind: PersistentVolume
      metadata:
        name: mongodb-pv
      spec:
        capacity:
          storage: 1Gi
        volumeMode: Filesystem
        accessModes:
          - ReadWriteOnce
        persistentVolumeReclaimPolicy: Retain
        storageClassName: manual
        hostPath:
          path: /data/mongodb

- Create a mongo-pvolc.yml (persistent volume claim) file. \
  `$ nano mongo-pvolc.yml`

      apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: mongodb-pvc
      spec:
        accessModes:
          - ReadWriteOnce
        storageClassName: manual
        resources:
          requests:
            storage: 1Gi


#### Create a deployment for MongoDB
- Create a mongo-dep.yml file. \
  `$ nano mongo-dep.yml`

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
              volumeMounts:
              - name: mongodb-data
                mountPath: /data/db

            volumes:
            - name: mongodb-data
              persistentVolumeClaim:
                claimName: mongodb-pvc

- Apply the deployment. \
  `$ kubectl apply -f mongo-dep.yml`


#### Create a service for MongoDB
- Create a mongo-svc.yml file. \
  `$ nano mongo-svc.yml`

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
  `$ kubectl apply -f mongo-svc.yml`


#### Create a deployment for Mongo Express
- Create a mongo-dep.yml file. \
  `$ nano mongoexpress-dep.yml`

        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: mongoexpress-deployment
        labels:
            app: mongoexpress
        spec:
        replicas: 1
        selector:
            matchLabels:
            app: mongoexpress
        template:
            metadata:
            labels:
                app: mongoexpress
            spec:
            containers:
            - name: mongoexpress
                image: mongo-express
                ports:
                - containerPort: 8081
                env:
                - name: ME_CONFIG_MONGODB_SERVER
                value: "mongo-service"



- Apply the deployment. \
  `$ kubectl apply -f mongoexpress-dep.yml`


#### Create a service for Mongo Express
- Create a mongoexpress-svc.yml file. \
  `$ nano mongoexpress-svc.yml`

        apiVersion: v1
        kind: Service
        metadata:
        name: mongoexpress-service
        spec:
        type: LoadBalancer
        selector:
            app: mongoexpress
        ports:
            - protocol: TCP
            port: 8081
            targetPort: 8081

- Apply the service. \
  `$ kubectl apply -f mongoexpress-svc.yml`



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
  ![](img/pod-status.png)

- Check logs to ensure nothing went wrong. \
  `$ kubectl logs pizzeria-pod` \
  ![](img/pod-logs.png)



#### Create a deployment for the Pizzeria app

- Create a pizzeria-dep.yml file. \
  `$ nano pizzeria-dep.yml`

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
  `$ kubectl apply -f pizzeria-dep.yml`

#### Create a service for the Pizzeria app
- Create a pizzeria-svc.yml file. \
  `$ nano pizzeria-svc.yml`

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
  `$ kubectl apply -f pizzeria-svc.yml`


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
- Create a proxy-dep.yml file. \
  `$ nano proxy-dep.yml`

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
                - containerPort: 443

- Apply the deployment. \
  `$ kubectl apply -f proxy-dep.yml`

#### Create a service for the nginx proxy
- Create a proxy-svc.yml file. \
  `$ nano proxy-svc.yml`

        apiVersion: v1
        kind: Service
        metadata:
        name: proxy-service
        spec:
        type: NodePort
        selector:
            app: proxy
        ports:
            - name: https
            port: 443


- Apply the service. \
  `$ kubectl apply -f proxy-svc.yml`


#### Expose the App

- First, run `minikube tunnel` either on a separate ssh instance
  or in the background by running `minikube tunnel &`.


- Expose the Nginx server to the internet. \
  `$ kubectl port-forward svc/proxy-service 8080:443 --address 0.0.0.0 &`
  - `svc/proxy-service` -The Service to run, in our case the nginx proxy.
  - `8080:443` -Forward the external port 8080 to internal port 443 (HTTPS). The external port is the one used to connect to the service over the internet.
  - `--address 0.0.0.0` -Specify which IP address to allow connections from. `0.0.0.0` will allow connections from any IP address.
  - `&` - An ampersand tells Linux to run the process in the background, leaving the shell available to use.

- Expose the Mongo Express server to the internet. \
  `$ kubectl port-forward svc/mongoexpress-service 8081:8081 --address 0.0.0.0 &`
  - `svc/mongoexpress-service` -The Service to run, in our case the mongo express server.
  - `8080:8081` -Forward the external port 8081 to internal port 8081 (HTTPS). The external port is the one used to connect to the service over the internet.
  - `--address 0.0.0.0` -Specify which IP address to allow connections from. `0.0.0.0` will allow connections from any IP address.
  - `&` - An ampersand tells Linux to run the process in the background, leaving the shell available to use.

