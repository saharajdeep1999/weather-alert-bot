import json
import os
import urllib.request
import urllib.error
import boto3
from datetime import datetime

DYNAMODB_TABLE = os.environ['DYNAMODB_TABLE']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
SECRET_ARN = os.environ['SECRET_ARN']

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
secrets = boto3.client('secretsmanager')


def fetch_with_retries(url, max_retries=3):
    """Fetch weather data with retry logic for resilience."""
    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=10) as response:
                return json.loads(response.read().decode())
        except urllib.error.URLError as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt == max_retries - 1:
                raise
    return None


def compute_heat_index(T, RH):
    """NOAA Heat Index formula."""
    HI = (-42.379
          + 2.04901523 * T
          + 10.14333127 * RH
          - 0.22475541 * T * RH
          - 0.00683783 * T * T
          - 0.05481717 * RH * RH
          + 0.00122874 * T * T * RH
          + 0.00085282 * T * RH * RH
          - 0.00000199 * T * T * RH * RH)
    return round(HI, 2)


def handler(event, context):
    try:
        url = ("https://api.open-meteo.com/v1/forecast"
               "?latitude=51.34&longitude=12.37"
               "&current=temperature_2m,relative_humidity_2m")

        data = fetch_with_retries(url)

        temp = data['current']['temperature_2m']
        humidity = data['current']['relative_humidity_2m']
        temp_f = (temp * 9 / 5) + 32
        heat_index = compute_heat_index(temp_f, humidity)

        table = dynamodb.Table(DYNAMODB_TABLE)
        timestamp = datetime.utcnow().isoformat()
        record = {
            'location': 'Leipzig',
            'timestamp': timestamp,
            'temp_c': temp,
            'temp_f': round(temp_f, 2),
            'humidity': humidity,
            'heat_index': heat_index
        }
        table.put_item(Item=record)

        secret = secrets.get_secret_value(SecretId=SECRET_ARN)
        threshold = json.loads(secret['SecretString'])['threshold']

        if heat_index > threshold:
            message = (f"HEAT ALERT: Heat index is {heat_index}F "
                       f"(threshold: {threshold}F) in Leipzig at {timestamp}.")
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=message,
                Subject="Weather Alert: High Heat Index"
            )

        return {"statusCode": 200, "body": json.dumps(record)}

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise