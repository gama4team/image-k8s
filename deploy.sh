#!/bin/bash

cd 0-terraform
/usr/bin/terraform init
/usr/bin/terraform fmt
/usr/bin/terraform apply -auto-approve

echo "Aguardando criação de maquinas ..."
sleep 10 # 10 segundos

echo "[ec2-k8s]" > ../1-ansible/hosts # cria arquivo
echo "$(/usr/bin/terraform output | grep public | awk '{print $2;exit}')" >> ../1-ansible/hosts # captura output faz split de espaco e replace de ",

echo "Aguardando criação de maquinas ..."
sleep 20 # 20 segundos

cd ../1-ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts provisionar.yml -u ubuntu --private-key /var/lib/jenkins/.ssh/id_rsa
