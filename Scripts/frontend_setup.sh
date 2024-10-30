#!/bin/bash
git clone https://github.com/KZhou1234/ecommerce_terraform_deployment.git
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs


#sed -i 's/http:\/\/private_ec2_ip:8000/http:\/\/${backend_ip}:8000/' package.json
#sed -i "s/http:\/\/private_ec2_ip:8000/http:\/\/${backend_ip}:8000/" package.json

npm i
export NODE_OPTIONS=--openssl-legacy-provider
npm start
