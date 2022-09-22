resource "aws_ecs_cluster" "ecs-boxer" {
  name = local.prefix
  tags = local.default_tags
}

resource "aws_ecs_task_definition" "ecs-boxer" {
  family                   = local.prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs-task-execution.arn

  container_definitions = jsonencode([
    {
      name      = local.prefix 
      image     = "${aws_ecr_repository.ecr-rep.repository_url}"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.logs.id}"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [{
        protocol      = "tcp"
        containerPort = 8081
      }]
      environment = [
        { "name" : "DB_HOST",
         "value" : "${aws_db_instance.box-instance.address}"},
        { "name" : "DB_USER", 
         "value" : "${var.db_username}"},
        { "name" : "DB_PASS",
         "value" : "${var.db_password}"},
        { "name" : "DB_DATABASE",
         "value" : "${var.db_name}"}
      ]
    }
  ])
  tags = local.default_tags
}

resource "aws_ecs_service" "ecs-boxer" {
  name            = local.prefix
  cluster         = aws_ecs_cluster.ecs-boxer.id
  task_definition = aws_ecs_task_definition.ecs-boxer.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on = [
    null_resource.images
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.ip-tg.arn
    container_name   = local.prefix
    container_port   = 8081
  }
  network_configuration {
    subnets = aws_subnet.private.*.id
    security_groups = [aws_security_group.intra.id]
  }
  tags = local.default_tags
}


resource "aws_cloudwatch_log_group" "logs" {
  name = "${local.prefix}-logs"
  tags = local.default_tags
}

resource "aws_iam_role" "ecs-task-execution" {
  name               = "${local.prefix}-ECS-task-execution"
  assume_role_policy = data.aws_iam_policy_document.role-policy.json
  tags               = local.default_tags
}

resource "aws_iam_policy" "ecs-logs-access" {
  name = "${local.prefix}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  tags = local.default_tags
}

resource "aws_iam_policy" "ecr-access" {
  name = "${local.prefix}-policy2"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "ecs-task-exec-policy" {
  role       = aws_iam_role.ecs-task-execution.name
  policy_arn = aws_iam_policy.ecs-logs-access.arn
}

resource "aws_iam_role_policy_attachment" "ecr-access" {
  role       = aws_iam_role.ecs-task-execution.name
  policy_arn = aws_iam_policy.ecr-access.arn
}

data "aws_iam_policy_document" "role-policy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}