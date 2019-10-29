### ECS

resource "aws_ecr_repository" "repo" {
  for_each             = var.aws_ecs_task_definition_container_definitions_var_container_image
  name                 = "${var.aws_ecs_cluster_name}-${var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].name}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "main" {
  for_each   = var.aws_ecs_task_definition_container_definitions_var_container_image
  repository = aws_ecr_repository.repo[each.key].name
  policy     = file("${path.module}/ecr_policy.tpl")

}

resource "aws_ecs_cluster" "main" {
  name = var.aws_ecs_cluster_name
  tags = var.environment_tags

}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}




resource "aws_iam_policy_attachment" "secrets_policy_attachment" {
  name       = "secrets_policy_attachment"
  roles      = ["${data.aws_iam_role.ecs_task_execution_role.name}"]
  policy_arn = aws_iam_policy.secrets_permissions_policy.arn
}


resource "aws_cloudwatch_log_group" "aws_ecs_task_definition_container_definitions_var_cloudwatch_log_group_name" {
  for_each = var.aws_ecs_task_definition_container_definitions_var_container_image
  name     = "${var.aws_ecs_cluster_name}-${var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].name}-logs"

  tags = var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].tags
}

# Genereate Randoms for secrets
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_-"
}

resource "random_uuid" "suffix" {}

# Set secrets
resource "aws_secretsmanager_secret" "service_secrets" {
  for_each    = var.service_secrets
  name        = "${var.aws_ecs_cluster_name}-${each.value.name}-${random_uuid.suffix.result}"
  description = each.value.name
}

resource "aws_secretsmanager_secret_version" "secrete_values" {
  for_each      = aws_secretsmanager_secret.service_secrets
  secret_id     = each.value.name
  secret_string = random_password.password.result

  depends_on = [aws_secretsmanager_secret.service_secrets]
}

# Get secrets
data "aws_secretsmanager_secret" "container_secrets" {
  for_each = aws_secretsmanager_secret.service_secrets
  name     = each.value.name

  depends_on = [aws_secretsmanager_secret.service_secrets]
}


locals {
  secrets_arn = jsonencode(values(data.aws_secretsmanager_secret.container_secrets)[*].arn)
}

resource "aws_iam_policy" "secrets_permissions_policy" {
  name = "${var.aws_ecs_cluster_name}-secrets_permissions_policy"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "secretsmanager:*",
                "cloudformation:CreateChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:DescribeStackResource",
                "cloudformation:DescribeStacks",
                "cloudformation:ExecuteChangeSet",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "kms:DescribeKey",
                "kms:ListAliases",
                "kms:ListKeys",
                "lambda:ListFunctions",
                "rds:DescribeDBClusters",
                "rds:DescribeDBInstances",
                "tag:GetResources",
                "ssm:*"
            ],
            "Effect": "Allow",
            "Resource": ["*"]

        },
        {
            "Action": [
                "lambda:AddPermission",
                "lambda:CreateFunction",
                "lambda:GetFunction",
                "lambda:InvokeFunction",
                "lambda:UpdateFunctionConfiguration"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:lambda:*:*:function:SecretsManager*"
        },
        {
            "Action": [
                "serverlessrepo:CreateCloudFormationChangeSet"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:serverlessrepo:*:*:applications/SecretsManager*"
        },
        {
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::awsserverlessrepo-changesets*"
        }
    ]
}
EOF
}


resource "aws_ecs_task_definition" "app" {
  for_each                 = var.aws_ecs_task_definition_container_definitions_var_container_image
  family                   = "${var.aws_ecs_cluster_name}-${var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.aws_ecs_task_definition_cpu
  memory                   = var.aws_ecs_task_definition_memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  tags                     = var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].tags

  depends_on = [aws_cloudwatch_log_group.aws_ecs_task_definition_container_definitions_var_cloudwatch_log_group_name]

  container_definitions = <<EOT
[
  {
    "image": "${var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].image}",
    "name": "app",
    "portMappings": [
      {
        "containerPort": ${var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].port},
        "hostPort": ${var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].port}
      }
    ],
    "secrets": [
        %{for secret in data.aws_secretsmanager_secret.container_secrets}
          {
              "valueFrom": "${secret.arn}",
              "name": "${secret.description}"
          },
        %{endfor}
        {
            "valueFrom": "0",
            "name": "0"
        }

    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.aws_region}",
        "awslogs-group": "${var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].name}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOT
}


resource "aws_ecs_service" "main" {
  for_each                = var.aws_ecs_task_definition_container_definitions_var_container_image
  name                    = var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].name
  cluster                 = aws_ecs_cluster.main.id
  task_definition         = aws_ecs_task_definition.app[each.key].arn
  desired_count           = var.app_count
  launch_type             = "FARGATE"
  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"
  tags                    = var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].tags

  network_configuration {
    security_groups  = [var.aws_security_group_ecs_tasks_id[each.key].id]
    subnets          = var.aws_subnets.*.id
    assign_public_ip = tobool(var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].assign_public_ip)
  }

  load_balancer {
    target_group_arn = var.target_group_arn[each.key].id
    container_name   = "app"
    container_port   = var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].port
  }

  depends_on = [aws_alb_listener.container_listener]
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "container_listener" {
  for_each          = var.aws_ecs_task_definition_container_definitions_var_container_image
  load_balancer_arn = var.aws_alb_main_id
  port              = var.aws_ecs_task_definition_container_definitions_var_container_image[each.key].port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.aws_acm_certificate_validation_default_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn[each.key].id
  }
}
