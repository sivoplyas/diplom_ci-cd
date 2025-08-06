#!/bin/bash

sudo docker run --rm -it --mount type=bind,source=./inventory,dst=/inventory --mount type=bind,source=/root/.ssh/public_id_ed25519,dst=/root/.ssh/ssh_key quay.io/kubespray/kubespray:v2.28.0 ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/ssh_key cluster.yml --become