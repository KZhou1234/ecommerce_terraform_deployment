#!/bin/bash
kura_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="
echo "$kura_key" >> /home/ubuntu/.ssh/authorized_keys

cd /home/ubuntu
git clone https://github.com/KZhou1234/ecommerce_terraform_deployment.git

echo "Updating system packages..."
sudo apt update -y
sudo apt install -y wget


# download and install node exporter
NODE_EXPORTER_VERSION="1.8.2"
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
tar xvfz node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin
rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64*

# create node exporter user
sudo useradd --no-create-home --shell /bin/false node_exporter

# create node exporter service file
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# reload systemd, start and enable Node Exporter service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# print public IP address and Node Exporter port
echo "Node Exporter installation complete. It's accessible at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9100/metrics"

#install nodejs
echo "Installing Node.js and npm..."
cd /home/ubuntu/ecommerce_terraform_deployment/frontend
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

#sed -i 's/http:\/\/private_ec2_ip:8000/http:\/\/${backend_ip}:8000/' package.json
#sed -i "s/http:\/\/private_ec2_ip:8000/http:\/\/${backend_ip}:8000/" package.json
sed -i "s/http:\/\/private_ec2_ip:8000/http:\/\/${backend_ip}:8000/" "/home/ubuntu/ecommerce_terraform_deployment/frontend/package.json"

sudo chown -R ubuntu:ubuntu /home/ubuntu/ecommerce_terraform_deployment/frontend
npm i
export NODE_OPTIONS=--openssl-legacy-provider
npm start
