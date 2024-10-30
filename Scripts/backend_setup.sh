#!/bin/bash
kura_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="

echo $kura_key >> /home/ubuntu/.ssh/authorized_keys
git clone https://github.com/KZhou1234/ecommerce_terraform_deployment.git
cd ecommerce_terraform_deployment
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

#sed -i 's/http:\/\/private_ec2_ip:8000/http:\/\/${backend_ip}:8000/' package.json
#sed -i "s/http:\/\/private_ec2_ip:8000/http:\/\/${backend_ip}:8000/" package.json

npm i
export NODE_OPTIONS=--openssl-legacy-provider
npm start

cd /home/ubuntu
git clone https://github.com/KZhou1234/ecommerce_terraform_deployment.git
# Installing Python and Python-related software for the application
cd /home/ubuntu/ecommerce_terraform_deployment/backend
sudo apt update

sudo apt install -y software-properties-common

sudo add-apt-repository -y ppa:deadsnakes/ppa

sudo apt install -y python3.9 python3.9-venv python3-pip



python3.9 -m venv venv
source venv/bin/activate
#cd ecommerce_terraform_deployment/backend
pip install -r requirements.txt


# add the private ip
backend_ip=$(hostname -i | awk '{print $1}')
#sed -i 's/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \["${backend_ip}"\]/' settings.py
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\"$backend_ip\"\]/" settings.py

#Create the tables in RDS: 
python manage.py makemigrations account
python manage.py makemigrations payments
python manage.py makemigrations product
python manage.py migrate

#Migrate the data from SQLite file to RDS:
python manage.py dumpdata --database=sqlite --natural-foreign --natural-primary -e contenttypes -e auth.Permission --indent 4 > datadump.json

python manage.py loaddata datadump.json

# run the Django application
python manage.py runserver 0.0.0.0:8000
