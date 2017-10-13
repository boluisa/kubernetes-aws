AWS_REGION = "us-east-1"
ALLOWED_NETWORK_CIDR = "0.0.0.0/0"
KEY_NAME = ""

default: terraform.tfvars

terraform.tfvars:
	@	sed \
	-e "s,%aws_region%,$(AWS_REGION)," \
	-e "s,%allowed_network_cidr%,$(ALLOWED_NETWORK_CIDR)," \
	-e "s,%aws_access_key%,$(AWS_ACCESS_KEY_ID)," \
	-e "s,%aws_secret_key%,$(AWS_SECRET_ACCESS_KEY)," \
		terraform.tfvars.tmpl > $@
