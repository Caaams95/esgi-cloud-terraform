resource "aws_iam_user" "kungfu_user" {
  name          = "tf-${var.username}-user"
  force_destroy = true
}

resource "aws_iam_access_key" "kungfu_access_key" {
  user = aws_iam_user.kungfu_user.name
}

data "aws_iam_policy" "full_read_only_policy" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "attach_full_read_only" {
  name       = "tf-attach-readonly"
  users      = [aws_iam_user.kungfu_user.name]
  policy_arn = data.aws_iam_policy.full_read_only_policy.arn
}

resource "aws_iam_user_policy" "kungfu_policy" {
  name = "tf-${var.policy_name}-policy"
  user = aws_iam_user.kungfu_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:AttachUserPolicy",
          "iam:CreateUser"
        ],
        "Resource" : [
          "arn:aws:iam::421751520950:user/fake-admin*",
          "arn:aws:iam::421751520950:policy/tf-fake-admin-policy"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "fake_admin_policy" {
  name = "tf-fake-admin-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",
          "ec2:DeleteSecurityGroup",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:ListPolicyVersions"
        ],

        "Resource" : "*"
      }
    ]
  })
}

# Hardening IAM
resource "aws_iam_group" "kungfu_users" {
  name = "kungfu-users"
}

resource "aws_iam_policy" "readonly_policy" {
  name        = "kungfu-ReadOnlyPolicy"
  description = "Policy with read-only access"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "s3:Get*",
          "s3:List*",
          "cloudwatch:GetMetricData",
          "logs:GetLogEvents",
          "iam:Get*",
          "iam:List*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_readonly" {
  group      = aws_iam_group.kungfu_users.name
  policy_arn = aws_iam_policy.readonly_policy.arn
}


resource "aws_iam_user_group_membership" "user_membership" {
  user = aws_iam_user.kungfu_user.name
  groups = [
    aws_iam_group.kungfu_users.name
  ]
}
