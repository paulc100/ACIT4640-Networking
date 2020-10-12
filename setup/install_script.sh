#!/bin/bash

#Variables
MONGO_FILE=/home/admin/setup/mongodb-org.repo
NGINX_FILE=/home/admin/setup/nginx.conf
DATABASE_FILE=/home/admin/setup/database.js
SELINUX_FILE=/home/admin/setup/config
SERVICE_FILE=/home/admin/setup/todoapp.service

GIT_APP=https://github.com/timoguic/ACIT4640-todo-app

APP_DIR=/home/todoapp/app
APP_USR_DIR=/home/todoapp

install_packages () {
    #Installing Packages
    sudo dnf install git -y
    sudo dnf install npm -y
    sudo dnf install nodejs -y

    sudo yum install nginx -y
    sudo systemctl enable nginx
}

setup_vm () {
    #MongoDB
    sudo mv ${MONGO_FILE} /etc/yum.repos.d/
    sudo dnf install -y mongodb-org
    sudo systemctl enable mongod

    #Nginx
    sudo mv -f ${NGINX_FILE} /etc/nginx/
    sudo systemctl restart nginx
}

create_app () {
    #Todoapp Setup
    sudo -u todoapp git clone ${GIT_APP} ${APP_DIR}
    sudo chmod 777 ${APP_USR_DIR}
    sudo mv -f ${DATABASE_FILE} ${APP_DIR}/config/

    #Install Application
    sudo -u todoapp npm install --prefix ${APP_DIR}

    #Systemd
    sudo mv ${SERVICE_FILE} /etc/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl enable todoapp
    sudo systemctl status todoapp
}

install_packages
setup_vm
create_app