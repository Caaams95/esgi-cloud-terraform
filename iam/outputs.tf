output "username" {
  value = aws_iam_user.kungfu_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.kungfu_access_key.id
}

output "access_key_secret" {
  value = aws_iam_access_key.kungfu_access_key.secret
}
output "user_arn" {
  value = aws_iam_user.kungfu_user.arn
}

# Hardening IAM
output "kungfu_user_name" {
  description = "The name of the IAM user created"
  value       = aws_iam_user.kungfu_user.name
}
