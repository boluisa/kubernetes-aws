variable "access_key" {
    description = "AWS access key."
}

variable "secret_key" {
    description = "AWS secret key."
}

variable "allowed_network" {
    description = "The CIDR of network that is allowed to access the cluster"
}

variable "region" {
    description = "The AWS region to create things in."
    default = "us-east-1"
}

variable "key_name" {
    description = "Name of the keypair to use in EC2."
    default = "terraform"
}

variable "key_path" {
    description = "Path to your private key."
    default = "~/.ssh/id_rsa"
}

variable "coreos_amis" {
    description = "CoreOS stable channel"
    default = {
        us-east-1      = "ami-6b1cd400"
        us-west-1      = "ami-bf8477fb"
        us-west-2      = "ami-f5a5a5c5"
        eu-west-1      = "ami-50f4b927"
        eu-central-1   = "ami-02211b1f"
        ap-northeast-1 = "ami-22d27b22"
        ap-southeast-2 = "ami-2b2e6911"
        ap-southeast-1 = "ami-0ef1f15c"
    }
}
