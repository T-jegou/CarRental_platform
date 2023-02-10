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

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name    = "${terraform.workspace}-vpc"
    Project = "${var.app_name}"
  }
}
