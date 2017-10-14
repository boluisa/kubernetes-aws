# Aws Terraform Starter Project

# Steps
* ssh-keygen -f my-key
* Edit aws.tf to use the generated public key
* Edit terraforms.tvars and enter access and secret key
* terraform plan
* terraform apply 

# Building an AWS Cluster with TF
* $pip install awscli

* EDIT ~/.aws/credentials file to name the credentials segment
* $ssh-keygen
* $ssh-agent bash
* $ssh-add <path to key>
  
* Install terraform  based on distro
* Install ansible based on the distro

* $aws route53 create-reusable-deligation-set --caller-reference 12345
* Save the JSON result
* $curl canhazip.com  // This will give your public ip address which can be used for dns later

