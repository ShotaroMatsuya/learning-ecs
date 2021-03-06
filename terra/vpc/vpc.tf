# Custome VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_tag_name}-${var.environment}"
  }
}
# Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = var.number_of_private_subnets
  vpc_id            = "${aws_vpc.custom_vpc.id}"
  cidr_block        = "${element(var.private_subnet_cidr_blocks, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags = {
    Name = "${var.private_subnet_tag_name}-${var.environment}"
  }
}

# Security Group

# Traffic to the ECS Cluster should only come from the NLB
# or AWS services through an AWS PrivateLink
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.security_group_ecs_tasks_name}-${var.environment}"
  description = var.security_group_ecs_tasks_description
  vpc_id      = "${aws_vpc.custom_vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.vpc_cidr_block]
  }

  # VPC endpoint for s3 is actually a gateway type, not an interface type, so we need specify the prefix list ID
  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    prefix_list_ids = [
      aws_vpc_endpoint.s3.prefix_list_id
    ]
  }
  # we want to allow communication between the VPC Endpoint NetworkInterfarces & the resources in the VPC 
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
