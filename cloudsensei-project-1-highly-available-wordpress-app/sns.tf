resource "aws_sns_topic" "topic" {
  name = "CPUUtilizationAlarm"
  tags = {
    Name = "TestAlarm"
  }
}

resource "aws_sns_topic_subscription" "email_subscription" {
  count     = length(var.email_address)
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.email_address[count.index]
}
