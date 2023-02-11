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

resource "aws_vpc" "CarPlatform-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${terraform.workspace}-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.CarPlatform-vpc.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${terraform.workspace}-PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.CarPlatform-vpc.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${terraform.workspace}-PrivateSubnet"
  }
}