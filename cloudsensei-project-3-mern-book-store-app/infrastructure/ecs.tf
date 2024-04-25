resource "aws_ecs_task_definition" "task" {
  family                   = "mern-task-def"
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072" 
  execution_role_arn       = aws_iam_role.role.arn
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      "name"                   = "mern-backend"
      "image"                  = "mayusb/mern-backend:lastest"
      "cpu"                    = 1024
      "memory"                 = 2048
      "memoryReservation"      = 1024
      "essential"              = true
      "environment"            = [
        { "name" = "PORT", "value" = "5000" },
        { "name" = "MONGO_DB", "value" = "mongodb+srv://root:root@cluster0.btk2bao.mongodb.net/?retryWrites=true&w=majority" },
      ]
      "portMappings"          = [
        {
          "containerPort" = 5000
          "hostPort"      = 5000
          "protocol"      = "tcp"
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.cluster.arn
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type = "FARGATE"

  network_configuration {
  subnets = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  security_groups = [aws_security_group.this.id]
  }

  load_balancer {
    container_name = "mern-frontend"
    container_port = 80
    target_group_arn = aws_lb_target_group.this.arn

  }

}