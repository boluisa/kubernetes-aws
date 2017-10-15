provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# IAM
#S3_access

#VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}

# Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  # uses interpolation syntax
  vpc_id = "${aws_vpc.vpc.id}"
}

# Routing tables
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
	cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
  tags {
	Name = "public"
  }
}

resource "aws_default_route_table" "private" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  tags {
 	  Name = "private"
  }
}

resource "aws_subnet" "public" { 
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-1a"
  
  tags {
	Name = "public"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-southeast-1a"
 
  tags {
  	Name = "private1"
  } 
}

resource "aws_subnet" "private2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-southeast-1b"
 
  tags {
    Name = "private2"
  } 
}

resource "aws_vpc_endpoint" "private-s3" {
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = ["${aws_vpc.vpc.main_route_table_id}", "${aws_route_table.public.id}"]
  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
POLICY
}

resource "aws_subnet" "rds1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-southeast-1a"
 
  tags {
    Name = "rds1"
  } 
}

resource "aws_subnet" "rds2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-southeast-1b"
 
  tags {
    Name = "rds2"
  } 
}

# Subnet association

resource "aws_route_table_association" "public_assoc" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id = "${aws_subnet.private1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id = "${aws_subnet.private2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds_subnet_group"
  subnet_ids = ["${aws_subnet.rds1.id}", "${aws_subnet.rds2.id}"]

  tags {
    Name = "rds_sng"
  }
}

# Security groups
# Public 
resource "aws_security_group" "public" {
  name = "sg_public"
  description = "Used for public and private instances of load balencer access"
  vpc_id = "${aws_vpc.vpc.id}"

  # SSH

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  # HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private 
resource "aws_security_group" "private" {
  name = "sg_private"
  description = "Used for private instances"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group 
resource "aws_security_group" "RDS" {
  name = "sg_rds"
  description = "Used for RDS instances"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "-1"
    cidr_blocks = ["${aws_security_group.public.id}", "${aws_security_group.private.id}"]
  }
}

# DB
resource "aws_db_instance" "db" {
  allocated_storage = 10
  engine            = "mysql"
  engine_version    = "5.6.27"
  instance_class    = "${var.db_instance_class}"
  name              = "${var.dbname}"
  username          = "${var.dbuser}"
  password          = "${var.dbpassword}"
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnet_group.name}"
  vpc_security_group_ids = ["${aws_security_group.RDS.id}"]
}

# Keypair
resource "aws_key_pair" "auth" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# IAM
# S3 Access

resource "aws_iam_instance_profile" "s3_access" {
  name  = "s3_access"
  role = "${aws_iam_role.s3_access.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "S3:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access" {
  name = "s3_access"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# S3 Bucket

resource "aws_s3_bucket" "code" {
  bucket = "${var.domainname}_code1234"
  acl    = "private"

  tags {
    Name        = "A Bucket"
    Environment = "Dev"
  }
}