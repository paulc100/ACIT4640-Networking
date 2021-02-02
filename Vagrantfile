Vagrant.configure("2") do |config|
  config.vm.box = "4640BOX"

  config.ssh.username = "admin"
  config.ssh.private_key_path = "./ansible/acit_admin_id_rsa"

  config.vm.synced_folder "./shared", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.linked_clone = true
  end

  config.vm.provision "file", source: "./ansible/", destination: "/home/admin/ansible"

  # Nginx VM Setup
  config.vm.define "TODO_HTTP_4640" do |todohttp|
    todohttp.vm.provider "virtualbox" do |vb|
      vb.name = "TODO_HTTP_4640"
      vb.memory = 1024
    end
    
    todohttp.vm.hostname = "todohttp.bcit.local"
    todohttp.vm.network "forwarded_port", guest: 80, host: 8800
    todohttp.vm.network "private_network", ip: "192.168.150.10"

    todohttp.vm.provision "ansible_local" do |ansible|
      ansible.provisioning_path = "/home/admin/ansible"
      ansible.playbook = "/home/admin/ansible/assignment.yaml"
    end
  end

  # Database VM Setup
  config.vm.define "TODO_DB_4640" do |db|
    db.vm.provider "virtualbox" do |vb|
      vb.name = "TODO_DB_4640"
      vb.memory = 1024
    end

    db.vm.hostname = "db.bcit.local"
    db.vm.network "private_network", ip: "192.168.150.30"
      
    db.vm.provision "ansible_local" do |ansible|
      ansible.provisioning_path = "/home/admin/ansible"
      ansible.playbook = "/home/admin/ansible/assignment.yaml"
    end
  end

  # APP VM Setup
  config.vm.define "TODO_APP_4640" do |app|
      app.vm.provider "virtualbox" do |vb|
          vb.name = "TODO_APP_4640"
          vb.memory = 1024
      end

      app.vm.hostname = "todoapp.bcit.local"
      app.vm.network "private_network", "ip": "192.168.150.20"

      app.vm.provision "ansible_local" do |ansible|
          ansible.provisioning_path = "/home/admin/ansible"
          ansible.playbook = "/home/admin/ansible/assignment.yaml"
      end
  end
end