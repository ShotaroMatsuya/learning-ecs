# defined vpc link
resource "aws_api_gateway_vpc_link" "main" {
  name       = "vpc-link-${var.app_name}"
  target_arn = [aws_lb.nlb.arn]

}
