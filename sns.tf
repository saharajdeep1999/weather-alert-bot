resource "aws_sns_topic" "weather_alerts" {
  name = "weather-alert-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.weather_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}