# aws.tf

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

resource "aws_key_pair" "my-key" {
  key_name   = "amazon-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ4Ivu/Fkmldh/diwHg9Ld7PqYYlMLB2AnFIXmLTkkbn2RzMg3ZHVmk2fBzZ1Ig+uZHeef725Yd0fa59t07S8eo4iOwX7U+WK72Av9XZ1KAq+Z7jcChsGB3YN/BHfFm3414WRzPJ02esg00RpdIPkU9Wm3koD4AhgIgeaN1j6BCMqNAWh8aBsJOtS/KbSTLQGBdK/FxImB6f5FuimoI75tyGjhffxXZPv8RIHiBwKF90bcYJg1ZLL3jsk49gnxV+JAon/yi4iBho5LkWzZqfX+JtIUuMIICNlm3xw30dccgO1Sh+tAO3K6axLV+vSK3nS061c/UMgmZ96vwOeTfCmh vishravars@MACC1MQ51XDDTY3"
}


provider "aws" {
	region = "ap-southeast-1"
  	access_key = "${var.AWS_ACCESS_KEY}"
  	secret_key = "${var.AWS_SECRET_KEY}"
}

# Create a web server
resource "aws_instance" "web" {
 	ami = "ami-9695e2f5"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.my-key.key_name}"
	tags {
		Name = "Mini Aws Terra"
	}
}
