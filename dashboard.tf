# dashboard.tf
# CloudWatch dashboard defined as code — ships with the infrastructure

data "aws_region" "current" {}

locals {
  dashboard_name = "weather-alert-dashboard"
}

resource "aws_cloudwatch_dashboard" "weather_alert" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# Weather Alert Bot Dashboard\n*Heat-index monitoring | Serverless | Terraform-managed*"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Invocations & Errors"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.weather_lambda.function_name, { stat = "Sum", period = 3600 }],
            [".", "Errors", ".", ".", { stat = "Sum", period = 3600, color = "#d62728" }]
          ]
          view    = "timeSeries"
          stacked = false
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Duration (ms)"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.weather_lambda.function_name, { stat = "Average", period = 3600 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB — Writes & Latency"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", aws_dynamodb_table.weather_data.name, { stat = "Sum", period = 3600 }],
            [".", "SuccessfulRequestLatency", ".", ".", { stat = "Average", period = 3600 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "SNS — Messages Published vs Delivered"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/SNS", "NumberOfMessagesPublished", "TopicName", aws_sns_topic.weather_alerts.name, { stat = "Sum", period = 3600 }],
            [".", "NumberOfNotificationsDelivered", ".", ".", { stat = "Sum", period = 3600 }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "alarm"
        x      = 0
        y      = 13
        width  = 24
        height = 3
        properties = {
          title = "Lambda Error Alarm Status"
          alarms = [
            aws_cloudwatch_metric_alarm.lambda_errors.arn
          ]
        }
      }
    ]
  })
}