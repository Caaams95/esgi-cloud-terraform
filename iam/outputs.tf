output "user_names" {
  value = {
    for user, key in aws_iam_user.users :
    user => key.name
  }
  sensitive = true
}

output "user_arn" {
  value = {
    for user, key in aws_iam_user.users :
    user => key.arn
  }
  sensitive = true
}

output "access_key_ids" {
  description = "Access key ID for each IAM user"
  value = {
    for user, key in aws_iam_access_key.keys :
    user => key.id
  }
  sensitive = true
}

output "access_key_secrets" {
  description = "Secret access key for each IAM user"
  value = {
    for user, key in aws_iam_access_key.keys :
    user => key.secret
  }
  sensitive = true
}