#!/bin/bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose  
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo '${dockerfile}' > /home/ubuntu/Dockerfile
echo '${dockercompose}' > /home/ubuntu/docker-compose.yml
echo '${entrypoint}' > /home/ubuntu/docker_entrypoint.sh

docker-compose -f /home/ubuntu/docker-compose.yml build
docker-compose -f /home/ubuntu/docker-compose.yml up -d --scale bombardier=${scale}
