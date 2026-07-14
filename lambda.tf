data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "weather_lambda" {
  function_name    = "weather-alert-lambda"
  runtime          = "python3.12"
  handler          = "lambda_function.handler"
  role             = data.aws_iam_role.lab_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.weather_data.name
      SNS_TOPIC_ARN  = aws_sns_topic.weather_alerts.arn
      SECRET_ARN     = aws_secretsmanager_secret.heat_threshold.arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}