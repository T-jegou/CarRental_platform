terraform {
  backend "remote" {
    hostname      = "app.terraform.io"
    organization  = "ekipDevops"

    workspaces {
      prefix = "CapRental-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

variable "app_name" {
  type    = string
  default = "WebApache"
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
