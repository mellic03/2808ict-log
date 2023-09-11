# Instance Setup

- Create the EC2 instance:
    - name: Assignment 1
    - OS Image: Ubuntu Server 22.04 LTS x86_64
    - Instance Type: t2.small
    - Security Configuration: Allow incoming on ports: SSH, HTTP, HTTPS and 8081.
    - Storage Configuration: 32 GiB of gp2 storage.

- Update apt packages and install any updates \
    `$ sudo apt update && sudo apt upgrade`

- Install some packages for later \
    `$ sudo apt install unzip`


## Install Docker Community Edition on the Instance

- Install prerequisite packages \
    `$ sudo apt install apt-transport-https ca-certificates curl software-properties-common`

##### Set up the apt Docker Repository
- Add the GPG key for the official Docker repository \
    `$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg`

- Add the Docker repository to apt sources \
    `$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null`

- Update apt packages again. We just added a new repository (Docker repository) to apt and update needs to be run so packages can be installed from it \
    `$ sudo apt update`

- Ensure docker-ce is now available through apt. This command should mention that docker-ce is available. \
    `$ apt-cache policy docker-ce`

##### Install and set up Docker Community Edition
- Install docker-ce \
    `$ sudo apt install docker-ce`

- Ensure the Docker systemd service is enabled and running. The output of this command should contain "Active: active (running) since ...". \
    `$ sudo systemctl status docker`

- If the service is not enabled or running, enable and run it \
    `$ sudo systemctl enable docker` \
    `$ sudo systemctl start docker`

- Ensure the docker command works \
    `$ docker`

- Add the ubuntu user account to the docker group. `$USER` is an environment variable which holds the username of the current user. You may need to exit the SSH session and rejoin for the change to take effect. \
    `$ sudo usermod -aG docker $USER`


### Download Docker Images

- Download the mongo and mongo-express docker images. The mongo image provides us with the MongoDB database itself and mongo-express provides a gui application for interacting with the database. \
    `$ docker pull mongo` \
    `$ docker pull mongo-express`
