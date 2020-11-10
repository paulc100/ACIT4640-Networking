# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "4640BOX"
    config.ssh.username = "admin"
    config.ssh.private_key_path = "files/acit_admin_id_rsa"

    config.vm.synced_folder ".", "/vagrant", disabled: true
    
    config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "2048"
    end

    config.vm.define "TODO_HTTP_4640" do |todohttp|
      todohttp.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_HTTP_4640"
        vb.memory = 2048
      end
      
      todohttp.vm.hostname = "todohttp.bcit.local"
      todohttp.vm.network "forwarded_port", guest: 80, host: 8888
      todohttp.vm.network "private_network", ip: "192.168.150.10"

      todohttp.vm.provision "file", source: "files/nginx.conf", destination: "/tmp/nginx.conf"
      todohttp.vm.provision "file", source: "files/config", destination: "/tmp/config"
      
      todohttp.vm.provision "shell", inline: <<-SHELL

        sudo firewall-cmd --zone=public --add-port=80/tcp
        sudo firewall-cmd --runtime-to-permanent

        dnf install -y git nginx

        git clone https://github.com/timoguic/ACIT4640-todo-app /var/www/app

        sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf

        sudo systemctl start nginx

      SHELL
    end

    config.vm.define "TODO_DB_4640" do |tododb|
      tododb.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_DB_4640"
        vb.memory = 1536
      end
      
      tododb.vm.hostname = "tododb.bcit.local"
      tododb.vm.network "private_network", ip: "192.168.150.30"

      tododb.vm.provision "file", source: "files/mongodb-org.repo", destination: "/tmp/mongodb-org.repo"
      tododb.vm.provision "file", source: "files/mongod.conf", destination: "/tmp/mongod.conf"
      
      tododb.vm.provision "shell", inline: <<-SHELL

        sudo firewall-cmd --zone=public --add-port=27017/tcp
        sudo firewall-cmd --runtime-to-permanent

        sudo mv /tmp/mongodb-org.repo /etc/yum.repos.d/mongodb-org.repo
        
        sudo mv /tmp/mongod.conf /etc/mongod.conf

        dnf install -y mongodb-org

        export LANG=C

        wget https://student:BCIT2020@acit4640.y.vu/docs/module06/resources/mongodb_ACIT4640.tgz -O /tmp/mongodb_ACIT4640.tgz

        sudo mv -f /tmp/mongodb_ACIT4640.tgz /mongodb_ACIT4640.tgz

        sudo systemctl start mongod

        yum install -y tar

        tar -zxf /mongodb_ACIT4640.tgz

        mongorestore -d acit4640 ./ACIT4640

      SHELL
    end

    config.vm.define "TODO_APP_4640" do |todoapp|
      todoapp.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_APP_4640"
        vb.memory = 2048
      end
      
      todoapp.vm.hostname = "todoapp.bcit.local"
      todoapp.vm.network "private_network", ip: "192.168.150.20"

      todoapp.vm.provision "file", source: "files/todoapp.service", destination: "/tmp/todoapp.service"
      todoapp.vm.provision "file", source: "files/database.js", destination: "/tmp/database.js"
      todoapp.vm.provision "file", source: "files/install_script.sh", destination: "/tmp/install_script.sh"
  
      todoapp.vm.provision "shell", inline: <<-SHELL

        sudo firewall-cmd --zone=public --add-port=8080/tcp
        sudo firewall-cmd --runtime-to-permanent

        useradd todoapp
        
        curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -

        dnf install -y git
        dnf install -y nodejs

        sudo -u todoapp bash /tmp/install_script.sh

        sudo mv /tmp/database.js /home/todoapp/app/config/database.js

        sudo mv /tmp/todoapp.service /etc/systemd/system

        sudo systemctl daemon-reload
        sudo systemctl start todoapp

      SHELL
    end
end