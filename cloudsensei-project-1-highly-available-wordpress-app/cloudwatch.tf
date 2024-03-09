resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.topic.arn]
  
  alarm_name = "cpu-utilization"
  dimensions = {
    AutoScalingGroupName = module.app.app_asg_name
  } 
}