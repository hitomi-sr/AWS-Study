# -------------------------
# LogGroup
# -------------------------

resource "aws_cloudwatch_log_group" "waf" {

  name              = "aws-waf-logs-study"
  retention_in_days = 7
}

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

  resource_arn            = aws_wafv2_web_acl.test.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
}

# -------------------------
# ALB関連付け
# -------------------------

resource "aws_wafv2_web_acl_association" "test" {

  resource_arn = aws_lb.test.arn
  web_acl_arn  = aws_wafv2_web_acl.test.arn
}