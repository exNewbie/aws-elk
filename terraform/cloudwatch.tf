resource "aws_cloudwatch_metric_alarm" "ProxyAlarm" {
  alarm_description         = "Trigger a recovery when instance status check fails for 15 consecutive minutes."
  namespace                 = "AWS/EC2"
  metric_name               = "CheckStatusFailedSystem"
  statistic                 = "Average"
  period                    = "60"
  evaluation_periods        = "15"
  comparison_operator       = "GreaterThanThreshold"
  alarm_name                = "ProxyAlarm"
  threshold                 = "0"
  alarm_actions             = [ "arn:aws:automate:${var.region}:ec2:recover" ]
  dimensions {
    InstanceId = "${aws_instance.ProxyAHost.id}"
  }
}
