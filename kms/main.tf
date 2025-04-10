resource "aws_kms_key" "kungfu_key" {
  description             = "KMS key for kungfu user"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "kungfu_alias" {
  name          = "alias/kungfu-key"
  target_key_id = aws_kms_key.kungfu_key.key_id
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key_policy" "kungfu_policy" {
  key_id = aws_kms_key.kungfu_key.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-policy-kungfu"
    Statement = [
      {
        Sid       = "AllowRootAccount"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowKungfuUserEncryptDecrypt"
        Effect    = "Allow"
        Principal = {
          AWS = "${var.kungfu_user_arn}"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}