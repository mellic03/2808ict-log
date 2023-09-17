# Task 2 - Docker Compose

## Pizzeria App (Front-End)

#### Aquire the Application

- Download and unzip the pizzeria app. \
    `$ wget http://formal-analysis.com/tmp/pizzeria.zip` \
    `$ unzip pizzeria.zip`


#### Build the Docker Image

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
      ENV MONGODB_URI="mongodb://backend:27017/"
      ENV PORT=4200
      ENV SECRET="secret"

      # Run the app on port 4200.
      EXPOSE 4200

      # Run the app with the command "node server.js".
      CMD ["node", "server.js"]


- Build the docker image, we'll name the image "pizzeria". \
    `$ docker build -t pizzeria .`


## Nginx Proxy

#### SSL Setup

- Make a directory for the nginx image  \
    `$ mkdir nginx-proxy` \
    `$ cd nginx-proxy`

- Generate the root CA private key (.key) and privacy enhanced mail (.pem) files. \
    `$ openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout RootCA.key -out RootCA.pem -subj "/C=US/CN=My-Root-CA"`

- Generate the root certificate (crt) from the pem file. \
    `$ openssl x509 -outform pem -in RootCA.pem -out RootCA.crt`

- Create the domains.ext file. \
    `$ nano domains.ext`

      authorityKeyIdentifier=keyid, issuer
      basicConstraints=CA:FALSE
      keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
      subjectAltName = @alt_names
      [alt_names]
      DNS.1 = localhost
      DNS.2 = fake1.local

- Generate the ssl certificate. \
    `$ openssl req -new -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=US/ST=YourState/L=YourCity/O=Example-Certificates/CN=localhost.local"`

- Take the csr to the CA to return a certificate. \
    `$ openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile domains.ext -out localhost.crt`

- Move openssl output to it's own directory to keep the directory neat. \
    `$ mkdir ssl` \
    `$ mv localhost.* ssl/` \
    `$ mv RootCA.* ssl/`

#### Nginx Configuration
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
              server frontend:4200;
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

#### Docker Configuration
- Write the Dockerfile. \
    `$ nano Dockerfile`

      # Use the nginx docker image as a base
      FROM nginx

      # Copy the nginx.conf we just wrote to the required location
      COPY nginx.conf /etc/nginx/nginx.conf

      # Copy the SSL cert + key to the required location
      COPY ssl/localhost.crt /etc/ssl/certs/localhost.crt
      COPY ssl/localhost.key /etc/ssl/private/localhost.key

- Build the Docker image. We'll name the image "nginx-proxy". \
    `$ docker build -t nginx-proxy .`
  
- Return to the pizzeria directory. \
    `$ cd ..`

## Docker Compose

#### Aquire the Application

- Check the Docker Compose releases page to find the latest version number. (https://github.com/docker/compose/releases)
  
- Substitiute <VERSION_NUMBER> with the current version of Docker Compose (including the v). \
    `$ sudo curl -L "https://github.com/docker/compose/releases/download/<VERSION_NUMBER>/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose`
- Make the file executable. \
    `$ sudo chmod +x /usr/local/bin/docker-compose `
- Check Docker Compose is working correctly. \
    `$ docker-compose –v`

#### Create YAML File

- Write docker-compose YAML file. \
    `$ nano docker-compose.yml`

      version: "3.9"
      services:

        mongodb:
          image: mongo
          container_name: backend
          volumes:
            - dbdata:/data/db
          networks:
            - backend
          ports:
            - "27017:27017"

        mongoexpress:
          image: mongo-express
          container_name: mongoexpress
          environment:
            - ME_CONFIG_MONGODB_SERVER=backend
          depends_on:
            - mongodb
          restart: unless-stopped 
          networks:
            - backend
          ports:
            - "8081:8081"

        pizzeria:
          image: pizzeria
          container_name: frontend
          depends_on:
            - mongodb
          restart: unless-stopped
          networks:
            - backend
            - frontend
          ports:
            - "4200:4200"

        proxy:
          image: nginx-proxy
          container_name: proxy
          depends_on:
            - pizzeria
          restart: unless-stopped
          volumes:
            - ./nginx-proxy/nginx.conf:/etc/nginx/nginx.conf:ro
            - ./nginx-proxy/ssl/localhost.crt:/etc/ssl/certs/localhost.crt
            - ./nginx-proxy/ssl/localhost.key:/etc/ssl/private/localhost.key
          networks:
            - frontend
          ports:
            - "80:80"
            - "443:443"

      volumes:
        dbdata:

      networks:
        backend:
        frontend:

  

## Run Containers

- Run docker-compose to start containers.
    `$ docker-compose up`

The Pizzeria application should now be accessible over HTTPS and the Mongo Express gui over HTTP on port 8081.

Logs
![image](https://github.com/mellic03/2808ict-log/assets/140577176/8b9b5724-0b0a-4678-8fce-afea37ab7180)
![image](https://github.com/mellic03/2808ict-log/assets/140577176/7f07eda8-f9a3-4f43-9593-f7dd4728a8cd)
![image](https://github.com/mellic03/2808ict-log/assets/140577176/4b4c2408-8596-475e-8cda-b73134a0dd45)

![image](https://github.com/mellic03/2808ict-log/assets/140577176/c1c792f7-210a-411a-aba7-e4121ad0f158)

![image](https://github.com/mellic03/2808ict-log/assets/140577176/dcf645b3-4020-4096-b952-ff4976c79dd1)
