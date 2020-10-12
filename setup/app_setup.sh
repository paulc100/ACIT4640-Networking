#!/bin/bash
scp -i ../.ssh/acit_admin_id_rsa -P 9222 -r setup admin@localhost:/www/
scp -i ../.ssh/acit_admin_id_rsa -P 9222 -r setup/ks.cfg admin@localhost:/www/
# ssh pxe sudo mv setup/ks.cfg /www
#ssh pxe sudo mv setup/ /www