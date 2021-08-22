resource "aws_api_gateway_rest_api" "main" {
  name = "api-gateway-${var.app_name}"
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resourdce_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "main" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.main.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  type = var.integration_input_type
  uri  = "http://${aws_lb.nlb.dns_name}:${var.app_port}/{proxy}"

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main.id
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "${var.env}-env"
  depends_on  = [aws_api_gateway_integration.main]

  variables = {
    resources = join(",", [aws_api_gateway_resource.main.id])
  }

  lifecycle {
    create_before_destroy = true
  }
}
