# -------------------------
# SNS Topic
# -------------------------

resource "aws_sns_topic" "alarm" {

  name = "alarm-topic"
}

# -------------------------
# CloudWatch Alarm
# -------------------------

resource "aws_cloudwatch_metric_alarm" "cpu" {

  alarm_name = "EC2-CPU-Alarm"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  alarm_description = "EC2 CPU utilization too high"

  dimensions = {
    InstanceId = aws_instance.test.id
  }

  alarm_actions = [
    aws_sns_topic.alarm.arn
  ]
}