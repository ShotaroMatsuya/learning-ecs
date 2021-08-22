# ECR (vpc endpoint - interface)

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet.*.id

  security_group_ids = [aws.aws_security_group.ecs_tasks.id]

  tags = {
    Name = "ECR Docker VPC Endpoint Interface - ${var.env}"
    Environment = var.env
  }
}


# CloudWatch(vpc endpoint - interface)

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet.*.id

  security_group_ids = [aws.aws_security_group.ecs_tasks.id]

  tags = {
    Name = "CloudWatch VPC Endpoint Interface - ${var.env}"
    Environment = var.env
  }
}


# S3 (vpc endpoint - Gateway)

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.custom_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.main_route_table_id] # TODO: Update with right reference

  tags = {
    Name      = "S3 VPC Endopoint Gateway - ${var.env}"
    Environment = var.env
  }
}
