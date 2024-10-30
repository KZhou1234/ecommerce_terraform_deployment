#!/bin/bash
git clone https://github.com/KZhou1234/ecommerce_terraform_deployment.git

python3.9 -m venv venv
source venv/bin/activate
cd ecommerce_terraform_deployment/backend
pip install -r requirements.txt

# add the private ip
#sed -i 's/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \["your_ip_address"\]/' settings.py
#sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\"${backend_ip}\"\]/" settings.py


# run the Django application
python manage.py runserver 0.0.0.0:8000
