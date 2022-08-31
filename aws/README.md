# AWS autoscaling group to run bombardier on AWS spot instances via VPN

# Prerequisites
1. AWS account and access keys
2. choco install awscli terraform -y

# Run
Run aws configure and specify credentials  
Change variables in variables.tf to set number of instances  
Review docker-compose.yml and configure vpn if have credentials  
See options for specific providers at https://github.com/qdm12/gluetun/wiki  
Run terraform apply




