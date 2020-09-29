#!

#ssh-copy-id -i ../.ssh/acit_admin_id_rsa.pub admin@localhost -p 7222

scp -r setup todoapp:
ssh todoapp bash setup/install_script.sh