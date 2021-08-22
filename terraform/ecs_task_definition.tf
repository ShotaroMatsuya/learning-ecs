resource "aws_ecs_task_definition" "main" {
    family = var.app_name
    executin_role_arn = aws_iam_role.ecs_execution.arn
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = var.fargate_cpu
    memory = var.fargate_memory

    container_definitions = jsonencode([
        {
            name: var.app_name,
            image: var.app_image,
            cpu: var.fargate_cpu,
            memory: var.fargate_memory,
            network_mode : "awsvpc",
            portMapings: [
                {
                    containerPort: var.app_port,
                    protocol: "tcp",
                    hostPort: var.app_port
                }
            ]
        }
    ])
  
}