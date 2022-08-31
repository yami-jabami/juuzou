#!/bin/bash
aws sts get-caller-identity
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        exit -1
}

echo Installing $1
if [ $# -ne 2 ]
  then
    echo "Waiting for 1 arguments "
    echo "Example:"
    echo "./run_all_terraform.sh 1212121212"
fi

echo "Installing $1"



declare -a REGIONS=("eu-north-1" "ap-south-1" "eu-west-3" "eu-west-2" "eu-west-1" "ap-northeast-3" "ap-northeast-2" "ap-northeast-1" "sa-east-1" "ca-central-1" "ap-southeast-1" "ap-southeast-2" "eu-central-1" "us-east-1" "us-east-2" "us-west-1" "us-west-2")
#$(aws ec2 describe-regions --all-regions | jq -r '.Regions | .[] | .RegionName + " " + .OptInStatus'  | grep -v not-opted-in | cut -d' ' -f1)
echo "{$REGIONS}"
ACCOUNT=$1

root=`pwd`
echo $root
# cd $root/create-tfstate-backend
# rm -rf .terraform .terraform.lock.hcl
# terraform init
# terraform apply -var="aws_s3_bucket=terraform${ACCOUNT}" --auto-approve
# terraform apply -var="aws_s3_bucket=terraform822206907601" --auto-approve


for AWS_REGION in "${REGIONS[@]}"
do
  #  export AWS_REGION=sa-east-1
   echo "+++++++++++{$AWS_REGION}"
   cd $root/aws
   rm -rf .terraform/terraform.tfstate .terraform.lock.hcl
   echo terraform init  -backend-config="bucket=terraform$ACCOUNT" -backend-config="key=terraform/${AWS_REGION}_bombardier_ua"
   #  -backend-config="region=us-east-1"
   terraform init  -backend-config="bucket=terraform$ACCOUNT"  -backend-config="key=terraform/${AWS_REGION}_bombardier_ua"
   #  -backend-config="region=us-east-1"
   terraform apply  -var="region=${AWS_REGION}" --auto-approve 
   echo "$AWS_REGION installed" >>result.txt
done