##
# VPC
##
resource "aws_vpc" "k8vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.k8vpc.id}"
}

##
# Public Subnet
##
resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.k8vpc.id}"
    cidr_block = "10.0.0.0/24"
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.k8vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gateway.id}"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public.id}"
}
