output "repo_name" {
  value      = aws_ecr_repository.ecr.name
  depends_on = [aws_ecr_repository.ecr]
}

output "registry_id" {
  value      = aws_ecr_repository.ecr.registry_id
  depends_on = [aws_ecr_repository.ecr]
}

output "repo_url" {
  value      = aws_ecr_repository.ecr.repository_url
  depends_on = [aws_ecr_repository.ecr]
}

output "arn" {
  value      = aws_ecr_repository.ecr.arn
  depends_on = [aws_ecr_repository.ecr]
}