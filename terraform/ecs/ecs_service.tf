resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.family
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = aws_subnet.private_subnet.*.id
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_tg.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }
  depends_on = [
    aws_ecs_task_definition.main
  ]
}
