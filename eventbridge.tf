resource "aws_scheduler_schedule" "weather_schedule" {
  name = "weather-alert-schedule"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 hour)"

  target {
    arn      = aws_lambda_function.weather_lambda.arn
    role_arn = data.aws_iam_role.lab_role.arn
  }
}