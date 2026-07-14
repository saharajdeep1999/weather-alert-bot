resource "aws_secretsmanager_secret" "heat_threshold" {
  name        = "weather-alert-threshold"
  description = "Heat index alert threshold (Fahrenheit)"
}

resource "aws_secretsmanager_secret_version" "heat_threshold_value" {
  secret_id     = aws_secretsmanager_secret.heat_threshold.id
  secret_string = jsonencode({ threshold = 90 })
}