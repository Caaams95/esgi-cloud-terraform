locals {
  users_with_kms_keys = {
    for user, conf in var.users :
    user => conf
    if try(length(conf.kms_keys), 0) > 0
  }
}

locals {
  users_inline = {
    for user, conf in var.users :
    user => conf.inline_policy
    if try(length(conf.inline_policy), 0) > 0
  }
}

resource "aws_iam_user" "users" {
  for_each = var.users

  name          = each.key
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "user_policies" {
  depends_on = [aws_iam_user.users]
  for_each = {
    for item in flatten([
      for user, conf in var.users : [
        for policy in conf.policies : {
          key    = "${user}-${basename(policy)}"
          user   = user
          policy = policy
        }
        if length(try(conf.policies, [])) > 0
      ]
    ]) : item.key => item
  }

  user       = each.value.user
  policy_arn = each.value.policy
}

resource "aws_iam_user_policy" "inline_policy" {
  depends_on = [aws_iam_user.users]
  for_each   = local.users_inline

  name   = each.value.name
  user   = each.key
  policy = each.value.policy
}

resource "aws_iam_user_policy" "kms_permissions" {
  depends_on = [aws_iam_user.users]
  for_each   = local.users_with_kms_keys

  name = "AllowUserKMSAccess"
  user = each.key

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = each.value.kms_keys
      }
    ]
  })
}



resource "aws_iam_access_key" "keys" {
  depends_on = [aws_iam_user.users]
  for_each   = var.users

  user = each.key
}