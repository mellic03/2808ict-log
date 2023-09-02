# 2808ict Assignment 1


# Task 1 - Individual Containers

- Install prerequisite packages \
    `$ sudo apt install blah blah blah...`

- Install docker \
    `$ sudo apt install docker`


- Download the mongo and mongo-express docker images \
    `$ docker pull mongo` \
    `$ docker pull mongo-express`


### Bridge Network
- Create a bridge network for container communication \
    `$ docker network create -d bridge bridge-net`


### Pizzeria App (Front-End)

- Download and uzip the pizzeria app \
    `$ wget http://formal-analysis.com/tmp/pizzeria.zip` \
    `$ unzip pizzeria.zip`

- Create the Dockerfile \
    `$ cd pizzeria` \
    `$ nano Dockerfile`

        # Use the node docker image as a base for this image.
        FROM node:latest

        WORKDIR /usr/src/app
        COPY package*.json ./

        # Install node.js dependencies (found in package.json).
        RUN npm install

        # Copy all directory contents.
        COPY . .

        # The pizzeria app requires these environment variables to be set.
        ENV MONGODB_URI="mongodb://mongo-backend:27017/"
        ENV PORT=4200
        ENV SECRET="secret"

        # Run the app on port 4200.
        EXPOSE 4200

        # Run the app with the command "node server.js".
        CMD ["node", "server.js"]

- Build the docker image \
    `$ docker build -t pizzeria .`


### Nginx Proxy
- Make a directory for the nginx image  \
    `$ mkdir nginx-proxy` \
    `$ cd nginx-proxy`

- Generate the ssl certificate \
    `$ openssl req -new -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=US/ST=YourState/L=YourCity/O=Example-Certificates/CN=localhost.local"`

    `$ openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile domains.ext -out localhost.crt`

- Move openssl output to it's own directory \
    `$ mkdir ssl` \
    `$ mv localhost.* ssl/` \
    `$ mv RootCA.* ssl/`

- Write the Dockerfile \
    `$ nano Dockerfile`

        FROM nginx

        COPY nginx.conf /etc/nginx/nginx.conf
        COPY ssl/localhost.crt /etc/ssl/certs/localhost.crt
        COPY ssl/localhost.key /etc/ssl/private/localhost.key

- Write the nginx configuration file \
    `$ nano nginx.conf`

        worker_processes 1;

        events {
            worker_connections 1024;
        }

        http {
            sendfile on;
            large_client_header_buffers 4 32k;

            upstream frontend-server {
                server node-frontend:4200;
            }

            server {
                listen 443 ssl;
                server_name localhost;
                ssl_certificate /etc/ssl/certs/localhost.crt;
                ssl_certificate_key /etc/ssl/private/localhost.key;

                location / {
                    proxy_pass http://frontend-server/;
                    proxy_connect_timeout 120s;
                    proxy_send_timeout 120s;
                    proxy_read_timeout 120s;
                    proxy_redirect off;
                    proxy_http_version 1.1;
                    proxy_cache_bypass $http_upgrade;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection keep-alive;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header X-Forwarded-Host $server_name;
                    proxy_buffer_size 128k;
                    proxy_buffers 4 256k;
                    proxy_busy_buffers_size 256k;
                }
            }
        }


### Start the Docker containers

Run the containers in this order, this is required because:
- Both Mongo Express and Nginx will try connecting to the MongoDB backend on startup.
- Nginx will try connecting to the frontend on startup.


1. MongoDB backend \
    `$ docker run --network=bridge-net --name=mongo-backend -p 27017:27017 -d mongo`

2. Mongo Express \
    `$ docker run --network=bridge-net --name=mongoexpress -p 8081:8081 -d mongo-express -e ME_CONFIG_MONGODB_SERVER=mongo-backend`

3. Pizzeria frontend \
    `$ docker run --network=bridge-net --name=node-frontend -p 4200:4200 -d pizzeria`

4. Nginx proxy \
    `$ docker run --network=bridge-net --name=nginx-proxy -p 80:80 -p 443:443 -d proxy`



# Task 2 - Docker Compose



# Task 3 - Minikube and Kubectl


