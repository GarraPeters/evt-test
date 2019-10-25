output "repository_url" {
  value = values(aws_ecr_repository.repo)[*].repository_url
}

output "secret_arn" {
  value = values(data.aws_secretsmanager_secret.container_secrets)[*].arn
}

