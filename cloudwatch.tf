resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/weather-alert-lambda"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "weather-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 2
  alarm_description   = "Alarm when Lambda errors > 2 in 5 min"
  dimensions = {
    FunctionName = aws_lambda_function.weather_lambda.function_name
  }
}