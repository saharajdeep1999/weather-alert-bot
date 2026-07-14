output "sns_topic_arn" {
  value = aws_sns_topic.weather_alerts.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.weather_data.name
}

output "lambda_function_name" {
  value = aws_lambda_function.weather_lambda.function_name
}