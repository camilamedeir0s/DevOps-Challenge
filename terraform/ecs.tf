resource "aws_ecs_cluster" "ascan_cluster" {
  name = "camila-ascan"
}

resource "aws_ecs_task_definition" "ascan_task" {
  family                   = "ascan-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "ascan-task",
      "image": "${aws_ecr_repository.repository.repository_url}",
      "essential": true,
      "portMappings": [
        {
            "hostPort": 80,
            "containerPort": 80,
            "protocol": "tcp"
        }
      ],
      "memory": 256,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "service" {
  name            = "ascan-service"
  cluster         = "${aws_ecs_cluster.ascan_cluster.id}"
  task_definition = "${aws_ecs_task_definition.ascan_task.arn}"
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name   = "${aws_ecs_task_definition.ascan_task.family}"
    container_port   = 80
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }

  depends_on = [
    aws_lb_listener.listener
  ]
}
