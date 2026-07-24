output "sns_topic_arn" {
  value = aws_sns_topic.weather_alerts.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.weather_data.name
}

output "lambda_function_name" {
  value = aws_lambda_function.weather_lambda.function_name
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.weather_alert.dashboard_name
}

output "cloudwatch_dashboard_url" {
  description = "Direct URL to the CloudWatch dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.weather_alert.dashboard_name}"
}