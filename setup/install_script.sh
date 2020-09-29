#!/bin/bash

#Variables
MONGO_FILE=setup/mongodb-org.repo
NGINX_FILE=setup/nginx.conf
DATABASE_FILE=setup/database.js
SELINUX_FILE=setup/config
SERVICE_FILE=setup/todoapp.service

GIT_APP=https://github.com/timoguic/ACIT4640-todo-app

APP_DIR=/home/todoapp/app
APP_USR_DIR=/home/todoapp

#Todoapp User
sudo useradd todoapp
echo "password" | sudo passwd --stdin todoapp

#Installing Packages
sudo dnf update -y
sudo dnf install git -y
sudo dnf install npm -y
sudo dnf install nodejs -y

sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

#MongoDB
sudo mv ${MONGO_FILE} /etc/yum.repos.d/
sudo dnf install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

#Todoapp Setup
sudo -u todoapp git clone ${GIT_APP} ${APP_DIR}
sudo chmod 777 ${APP_USR_DIR}
sudo mv -f ${DATABASE_FILE} ${APP_DIR}/config/

#Disable SE Linux
sudo setenforce 0
sudo mv -f ${SELINUX_FILE} /etc/selinux/

#Firewall Config
sudo firewall-cmd --zone=public --add-service=http
sudo firewall-cmd --zone=public --add-service=https
sudo firewall-cmd --zone=public --add-port=80/tcp
sudo firewall-cmd --runtime-to-permanent

#Nginx
sudo mv -f ${NGINX_FILE} /etc/nginx/
sudo systemctl restart nginx

#Install Application
sudo -u todoapp npm install --prefix ${APP_DIR}

#Systemd
sudo mv ${SERVICE_FILE} /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start todoapp
sudo systemctl enable todoapp
sudo systemctl status todoapp