# -------------------------
# WebACL
# -------------------------

resource "aws_wafv2_web_acl" "test" {

  name  = "aws-study-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "awsStudyACL"
    sampled_requests_enabled   = true
  }
}

# -------------------------
# Logging
# -------------------------

resource "aws_wafv2_web_acl_logging_configuration" "test" {

  resource_arn = aws_wafv2_web_acl.test.arn
  log_destination_configs = [
    aws_kinesis_firehose_delivery_stream.waf.arn
  ]

  depends_on = [
    aws_kinesis_firehose_delivery_stream.waf
  ]
}

# -------------------------
# ALB関連付け
# -------------------------

resource "aws_wafv2_web_acl_association" "test" {

  resource_arn = aws_lb.test.arn
  web_acl_arn  = aws_wafv2_web_acl.test.arn
}

# -------------------------
# S3 Bucket
# -------------------------

resource "aws_s3_bucket" "waf_log" {

  bucket = "aws-study-waf-log-hitomi" # バケット名
}

# -------------------------
# IAM Role for Firehose
# -------------------------

resource "aws_iam_role" "firehose" {

  name = "firehose-waf-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# -------------------------
# IAM Policy
# -------------------------

resource "aws_iam_role_policy" "firehose" {

  name = "firehose-waf-policy"
  role = aws_iam_role.firehose.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # S3 Bucket 自体への権限
      {
        Effect = "Allow"

        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.waf_log.arn
      },

      # S3 オブジェクト操作権限
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload"
        ]

        Resource = "${aws_s3_bucket.waf_log.arn}/*"
      }

    ]
  })
}

# -------------------------
# Firehose
# -------------------------

resource "aws_kinesis_firehose_delivery_stream" "waf" {

  name        = "aws-waf-logs-study"
  destination = "extended_s3"

  extended_s3_configuration {

    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.waf_log.arn
  }
}
