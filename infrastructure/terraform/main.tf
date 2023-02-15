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
  ami                         = "ami-0b752bf1df193a6c4"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.allow_nat.id]
  source_dest_check           = false
  associate_public_ip_address = true

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
  name        = "allow_web-${terraform.workspace}"
  vpc_id      = aws_vpc.vpc.id
  description = "Allow inbound traffic"

  tags = {
    Name    = "${terraform.workspace}-NAT-SG"
    Project = "${var.app_name}"
  }
}

resource "aws_security_group_rule" "egress_nat" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_nat.id
}

# Allow inbound traffic from each private subnet and public subnet to the NAT instance, do a loop to create the rules
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


# Repository for ecr and policy
resource "aws_ecr_repository_policy" "carPlatform-repo-policy" {
  repository = "car_platform_repository"
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the car_platform_repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  }
  EOF
}


resource "aws_ecs_task_definition" "car_api_task" {
  family                   = "carPlatformApp-${terraform.workspace}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::560022977783:role/ecsTaskExecutionRole"

  # Should depends on the ecr role policy
  depends_on = [aws_ecr_repository_policy.carPlatform-repo-policy]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${terraform.workspace}-api",
    "cpu": 256,
    "memory" : 512,
    "essential": true,
    "image": "${var.ECR_ARN}",
    "environment": [
      {
        "name" : "ATLAS_MONGO_PASSWORD",
        "value" : "${var.ATLAS_MONGO_PASSWORD}"
      },
      {
        "name" : "ATLAS_MONGO_DATABASE",
        "value" : "${var.ATLAS_MONGO_DATABASE}"
      },
      {
        "name" : "ATLAS_MONGO_HOST",
        "value" : "${var.ATLAS_MONGO_HOST}"
      },
      {
        "name" : "ATLAS_MONGO_USERNAME",
        "value" : "${var.ATLAS_MONGO_USERNAME}"
      }
    ],
    "portMappings": [
      {
        "containerPort": 4000,
        "hostPort": 4000
      }
    ]
  }
]
TASK_DEFINITION

  # add execution role
  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-TD"
  }
}

# Create  aws ecs cluster and associate it with the vpc created and the subnets
resource "aws_ecs_cluster" "car_platform_cluster" {
  name = "carPlatformApp-${terraform.workspace}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-EC"
  }
}


# SG ELB
resource "aws_security_group" "http_sg_alb" {
  name_prefix = "${terraform.workspace}-SG-HTTP-ALB-"
  description = "Allow inbound traffic on port 4000"
  vpc_id      = aws_vpc.vpc.id

  # Autoriser le trafic entrant sur le port 4000 en HTTP
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser le trafic sortant sur le tout les ports et protocoles de tout les subnet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = aws_subnet.private_subnet.*.cidr_block
  }

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-SG-HTTP-ALB"
  }
}

# Create target group
resource "aws_lb_target_group" "car_platform_target_group" {
  name        = "${terraform.workspace}-TG"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    port                = 4000
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/api/healthcheck"
  }

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-TG"
  }
}

# Create ALB listener
resource "aws_lb_listener" "car_platform_listener" {
  load_balancer_arn = aws_lb.car_platform_alb.arn
  port              = "4000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.car_platform_target_group.arn
  }

  depends_on = [
    aws_lb.car_platform_alb,
    aws_lb_target_group.car_platform_target_group
  ]

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-ALB-LISTENER"
  }
}

# Create ALB
resource "aws_lb" "car_platform_alb" {
  name               = "${terraform.workspace}-ALB"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.http_sg_alb.id]
  subnets            = aws_subnet.public_subnet.*.id

  enable_deletion_protection = false

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-ALB"
  }
}

# Create fargate service security group
resource "aws_security_group" "fargate_service_sg" {
  name        = "fargate_service_sg-${terraform.workspace}"
  description = "Allow inbound traffic on port 4000"
  vpc_id      = aws_vpc.vpc.id

  # Autoriser le trafic entrant sur le port 4000 en HTTP
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = aws_subnet.public_subnet.*.cidr_block
  }

  # Autoriser le trafic sortant sur le tout les ports et protocoles de tout les subnet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-SG-FARGATE-SERVICE"
  }
}

# Create fargate service
resource "aws_ecs_service" "car_platform_service" {
  name            = "carPlatformApp-${terraform.workspace}"
  cluster         = aws_ecs_cluster.car_platform_cluster.id
  task_definition = aws_ecs_task_definition.car_api_task.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private_subnet.*.id
    security_groups  = [aws_security_group.fargate_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.car_platform_target_group.arn
    container_name   = "${terraform.workspace}-api"
    container_port   = 4000
  }

  depends_on = [
    aws_lb.car_platform_alb
  ]

  tags = {
    Project = "${var.app_name}"
    Name    = "${terraform.workspace}-ES"
  }
}