#!/bin/bash

SSH_KEY=acit_admin_id_rsa
 
vbmg() {
    VBoxManage.exe "$@";
}
 
#Check for the existence of a running virtual machine
find_machine() {
    local status=$(vbmg list vms | grep "$1" | cut -d'"' -f2)
    if [ -z "$status" ]; then return 1; else return 0; fi
}
 
find_running_machine() {
    local status=$(vbmg list runningvms | grep "$1" | cut -d'"' -f2)
    if [ -z "$status" ]; then return 1; else return 0; fi
}
 
#Create a NAT network
vbmg natnetwork add --netname "NET_4640" --enable --dhcp off \
    --network 192.168.150.0/24 \
    --port-forward-4 "PXESSH:tcp:[]:9222:[192.168.150.10]:22" \
    --port-forward-4 "VMHTTP:tcp:[]:8080:[192.168.150.200]:8080" \
	--port-forward-4 "TODOAPPSSH:tcp:[]:8022:[192.168.150.200]:22"

vbmg modifyvm "PXE4640" \
    --nic1 natnetwork --nat-network1 NET_4640 --cableconnected1 on

if find_running_machine "PXE4640"
then
    echo "PXE4640 is running"
else
    echo "PXE4640 is not running"
    vbmg startvm PXE4640
    #Wait for PXE to be running
    while /bin/true; do
        ssh -i ${SSH_KEY} -p 9222 \
            -q -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            admin@localhost exit
        if [ $? -ne 0 ]; then
                echo "PXE server is not up, sleeping..."
                sleep 5
        else
                echo "PXE server is up and running!"
				scp -i ${SSH_KEY} -P 9222 -r setup admin@localhost:/www/
				scp -i ${SSH_KEY} -P 9222 -r setup/ks.cfg admin@localhost:/www/
                break
        fi
    done
fi
 
if find_machine "TODO4640A"
then
    echo "TODO4640A exists!"
    vbmg startvm TODO4640A
else
    echo "TODO4640A does not exist."
    #Create a virtual machine
    vbmg createvm --name "TODO4640A" --ostype RedHat_64 --register
 
    #Change settings of virtual machine
    vbmg modifyvm "TODO4640A" \
        --memory 4000 \
        --nic1 natnetwork --nat-network1 NET_4640 --cableconnected1 on \
        --boot1 disk --boot2 net --boot3 none --boot4 none \
        --graphicscontroller vmsvga
 
    #Create the storage controller
    vbmg storagectl "TODO4640A" --name "STORAGE4640" --add sata --controller IntelAHCI
 
    #Find the path to the virtual machine’s folder
    SED_PROGRAM="/^Config file:/ { s|^Config file: \+\(.\+\)\\\\.\+\.vbox|\1|; s|\\\\|/|gp }"
    VM_FOLDER=$(vbmg showvminfo TODO4640A | sed -ne "$SED_PROGRAM" | tr -d "\r\n")
 
    #Create the hard disk file
    vbmg createmedium disk --filename "${VM_FOLDER}/STORAGE4640.vdi" --size 10240
 
    #Connect the disk to the controller
    vbmg storageattach "TODO4640A" --storagectl "STORAGE4640" --port 0 --device 0 --type hdd --medium "${VM_FOLDER}/STORAGE4640.vdi"
 
    echo "TODO4640A created successfully!"
    vbmg startvm TODO4640A
fi

$SHELL