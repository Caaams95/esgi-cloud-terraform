# Obtenir l'ID du compte AWS (utilisé dans la policy S3 pour CloudTrail)
data "aws_caller_identity" "current" {}

# Génère un ID unique pour éviter les conflits de noms
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Bucket S3 pour logs CloudTrail
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "cloudtrail-logs-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "cloudtrail-logs"
  }
}

# Bucket policy pour permettre à CloudTrail d'écrire dans le bucket
resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid       = "AWSCloudTrailWrite",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail qui logge toutes les actions API AWS vers S3
resource "aws_cloudtrail" "trail" {
  name                          = "kungfu-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  enable_logging                = true

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_policy]
}

# Log group pour les VPC Flow Logs avec suffixe aléatoire
resource "aws_cloudwatch_log_group" "vpc_flow" {
  name = "/aws/vpc/flowlogs-${random_id.bucket_id.hex}"
}

# IAM role que les VPC Flow Logs vont assumer pour publier dans CloudWatch
resource "aws_iam_role" "vpc_flowlog_role" {
  name = "vpc-flowlog-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Permissions pour que le rôle puisse écrire dans CloudWatch Logs
resource "aws_iam_role_policy" "vpc_flowlog_policy" {
  name = "vpc-flowlog-policy"
  role = aws_iam_role.vpc_flowlog_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Activer les Flow Logs sur le VPC
resource "aws_flow_log" "vpc" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow.arn
  iam_role_arn         = aws_iam_role.vpc_flowlog_role.arn
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
}
