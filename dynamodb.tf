resource "aws_dynamodb_table" "weather_data" {
  name         = "weather-alerts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "location"
  range_key    = "timestamp"

  attribute {
    name = "location"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}