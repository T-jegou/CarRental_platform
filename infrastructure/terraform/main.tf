terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ekipDevops"

    workspaces {
      prefix = "CarRental-"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

variable "app_name" {
  type    = string
  default = "CarPlatform"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name    = "${terraform.workspace}-VPC"
    Project = "${var.app_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${terraform.workspace}-igw"
    Project = "${var.app_name}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${terraform.workspace}-PublicSubnet"
    Project = "${var.app_name}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${terraform.workspace}-PrivateSubnet"
    Project = "${var.app_name}"
  }
}

# NAT INSTANCE, we prefer creating a NAT instance instead of NAT gateway because of the cost
resource "aws_instance" "nat" {
  ami                    = "ami-0b752bf1df193a6c4"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.allow_nat.id]
  source_dest_check      = false

  user_data = <<-EOF
       #!/bin/bash
       sysctl -w net.ipv4.ip_forward=1 /sbin/
       iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF

  tags = {
    Name    = "${terraform.workspace}-NAT"
    Project = "${var.app_name}"
  }
}

# Nat SG
resource "aws_security_group" "allow_nat" {
  name        = "allow_web"
  vpc_id      = aws_vpc.vpc.id
  description = "Allow inbound traffic"
}

resource "aws_security_group_rule" "egress_nat" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_nat.id
}

# Allow inbound traffic from each private subnet to the NAT instance, do a loop to create the rules
resource "aws_security_group_rule" "allow_nat" {
  count             = length(data.aws_availability_zones.available.names)
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_subnet.private_subnet[count.index].cidr_block]
  security_group_id = aws_security_group.allow_nat.id
}


# Route Table
# Private
## Use Main Route Table
resource "aws_default_route_table" "main-private" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-RT-Private"
  }
}

## Custom public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-RT-Public"
  }
}

## Associate public route table to public subnet
resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

## Associate private route table to private subnet
resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_default_route_table.main-private.id
}
