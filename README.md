Group 7 : Capstone Project : Weather Alert Bot

Cloud Solutions  | SRH Leipzig University

Members : 
1. Rajdeep Saha                      (100005470)
2. Almaskhan Anwarkhan Kazi          (100007165)

Lecturer: Kendrick Bollens
---
Project Overview
A serverless weather alert service built on AWS using Terraform. The system fetches weather data from the free Open-Meteo API every hour, computes the heat index from temperature and humidity, stores enriched records in DynamoDB, and sends email alerts via SNS when the heat index exceeds a configurable threshold stored in AWS Secrets Manager.

Architecture
```
┌─────────────────────────────────────────────────────────────────────────┐
│                         OBSERVABILITY LAYER (IaC)                       │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  CloudWatch Dashboard (dashboard.tf)                            │    │
│  │  ├── Lambda Invocations & Errors widget                         │    │
│  │  ├── Lambda Duration widget                                     │    │
│  │  ├── DynamoDB Writes & Latency widget                           │    │
│  │  ├── SNS Messages Published/Delivered widget                    │    │
│  │  └── Lambda Error Alarm Status widget                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                              ▲         ▲         ▲         ▲            │
└──────────────────────────────┼─────────┼─────────┼─────────┼────────────┘
                               │         │         │         │
                               │         │         │         │
EventBridge Scheduler (1h) ────┼─────────┼─────────┼─────────┼──► Lambda (Python 3.12)
                               │         │         │         │      │
                               │         │         │         │      ▼
                               │         │         │         │  Open-Meteo API
                               │         │         │         │      │
                               │         │         │         ▼      ▼
                               │         │         │    DynamoDB (enriched data)
                               │         │         │         │
                               │         │         │         ▼
                               │         │         │  Secrets Manager (threshold)
                               │         │         │         │
                               │         │         │         ▼
                               │         │         │      SNS (email alert)
                               │         │         │
                               │         │         └────────────────────┐
                               │         └────────────────────────────┤
                               └──────────────────────────────────────┤
                                                                      ▼
                                                              CloudWatch Logs
                                                              CloudWatch Alarms
```



AWS Services Used

| Service                          | Purpose                                                                                             |
| -------------------------------- | --------------------------------------------------------------------------------------------------- |
| **AWS Lambda**                   | Serverless compute for weather fetching, heat-index calculation, threshold comparison, and alerting |
| **Amazon EventBridge Scheduler** | Hourly trigger for Lambda execution                                                                 |
| **Amazon DynamoDB**              | Time-series storage of enriched weather records                                                     |
| **AWS Secrets Manager**          | Secure storage of heat-index alert threshold (e.g., 90°F)                                           |
| **Amazon SNS**                   | Email notification delivery when threshold is exceeded                                              |
| **Amazon CloudWatch**            | Execution logging, error alarming, and **dashboard visualization**                                  |

Prerequisites

| Requirement     | Details                                                               |
| --------------- | --------------------------------------------------------------------- |
| **AWS Account** | AWS Learner Lab with active session credentials                       |
| **Terraform**   | Version >= 1.5                                                        |
| **AWS CLI**     | Configured with Learner Lab access key, secret key, and session token |
| **Git**         | Optional, for version control and submission                          |

What Changed

| Section               | Update                                                                                                                                    |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **AWS Services Used** | Reformatted as a clean markdown table; expanded Lambda description to include threshold comparison; added dashboard to CloudWatch purpose |
| **Prerequisites**     | Added as a matching table for consistency                                                                                                 |


Project Structure
```
weather-alert-bot/
├── main.tf                        # Provider, backend, AWS region
├── variables.tf                   # Input variables (email, region, etc.)
├── lambda.tf                      # Lambda function, IAM role, zip packaging
├── eventbridge.tf                 # EventBridge scheduler (hourly trigger)
├── dynamodb.tf                    # DynamoDB table (location + timestamp keys)
├── sns.tf                         # SNS topic and email subscription
├── secretsmanager.tf              # Heat-index threshold secret
├── cloudwatch.tf                  # Log group and Lambda error alarm
├── dashboard.tf                   # CloudWatch dashboard as code (NEW)
├── outputs.tf                     # ARNs, names, dashboard URL (UPDATED)
├── terraform.tfstate              # Terraform state (local, do not commit)
├── terraform.tfstate.backup
├── lambda.zip                     # Auto-generated deployment package
├── .gitignore                     # Ignore .env, state files, zip
├── .env                           # Local credentials (ignored by Git)
├── response.json                  # Test output (ignored by Git)
└── lambda/
    └── lambda_function.py         # Python handler (UPDATED: Decimal fix)

```
Deployment
1. Clone the Repository
```bash
git clone https://github.com/saharajdeep1999/weather-alert-bot.git
cd weather-alert-bot
```
2. Set AWS Credentials
From your AWS Learner Lab:
```powershell
$env:AWS\_ACCESS\_KEY\_ID = "your-access-key"
$env:AWS\_SECRET\_ACCESS\_KEY = "your-secret-key"
$env:AWS\_SESSION\_TOKEN = "your-session-token"
$env:AWS\_REGION = "us-east-1"
```
3. Update Email Address
Edit `variables.tf` and replace the default email:
```hcl
variable "alert\_email" {
  description = "Email for SNS alerts"
  default     = "raj1999saha@gmail.com"
}
```
4. Deploy with Terraform
```bash
terraform init
terraform plan
terraform apply
```
Type `yes` when prompted.
5. Confirm SNS Subscription
Check your email inbox for an AWS subscription confirmation email. Click "Confirm subscription" to enable alerts.
6. Test the Lambda
```bash
aws lambda invoke --function-name weather-alert-lambda --payload '{}' response.json
cat response.json
```
How It Works ?
EventBridge Scheduler triggers the Lambda function every hour
Lambda fetches current weather data from Open-Meteo API (Leipzig: 51.34°N, 12.37°E)
Heat Index Calculation using the NOAA formula:
```
   HI = c1 + c2\*T + c3\*RH + c4\*T\*RH + c5\*T² + c6\*RH² + c7\*T²\*RH + c8\*T\*RH² + c9\*T²\*RH²

Coeffiecnts
| Coefficient | Value        | Term             |
| ----------- | ------------ | ---------------- |
|  c_1        | −42.379      | Constant         |
|  c_2        | +2.04901523  |  T               |
|  c_3        | +10.14333127 |  RH              |
|  c_4        | −0.22475541  |  T \cdot RH      |
|  c_5        | −0.00683783  |  T^2             |
|  c_6        | −0.05481717  |  RH^2            |
|  c_7        | +0.00122874  |  T^2 \cdot RH    |
|  c_8        | +0.00085282  |  T \cdot RH^2    |
|  c_9        | −0.00000199  |  T^2 \cdot RH^2  |

Variables
| Variable | Description                | Source                                                                    |
| -------- | -------------------------- | ------------------------------------------------------------------------- |
|  T       | Temperature in **°F**      | Converted from Open-Meteo °C:  T_{°F} = (T_{°C} \times \frac{9}{5}) + 32  |
|  RH      | Relative humidity in **%** | Open-Meteo `relative_humidity_2m`                                         |


Python Implementation
def compute_heat_index(T, RH):
    """NOAA simplified heat index formula."""
    HI = (-42.379
          + 2.04901523 * T
          + 10.14333127 * RH
          - 0.22475541 * T * RH
          - 0.00683783 * T**2
          - 0.05481717 * RH**2
          + 0.00122874 * T**2 * RH
          + 0.00085282 * T * RH**2
          - 0.00000199 * T**2 * RH**2)
    return round(HI, 2)
   ```
Data Flow
Data Enrichment — Lambda fetches raw weather data from Open-Meteo, computes the NOAA heat index from temperature (°C → °F) and humidity, and stores the enriched record (location, timestamp, temperature, humidity, heat index) in DynamoDB.

Threshold Check — Lambda retrieves the heat-index threshold from Secrets Manager. If the computed heat index exceeds the threshold, it publishes an SNS email alert.

Monitoring & Observability — CloudWatch Logs capture every execution. A CloudWatch Alarm triggers if Lambda errors exceed 2 in 5 minutes. A CloudWatch Dashboard (defined in dashboard.tf) visualizes Lambda invocations, duration, DynamoDB writes, SNS deliveries, and alarm status all deployed automatically with the infrastructure.

```

Type `yes` when prompted.
---

```
| Decision          | Chose                      | Rejected                  | Pillar                        | Reason                                                                   |
| ----------------- | -------------------------- | ------------------------- | ----------------------------- | ------------------------------------------------------------------------ |
| **Database**      | DynamoDB on-demand         | RDS PostgreSQL            | Cost                          | No idle instance cost; pay-per-request fits the \$100 Learner Lab budget |
| **Compute**       | AWS Lambda                 | EC2 / ECS                 | Cost + Operational Excellence | Serverless, no patching, free tier covers the load                       |
| **Weather API**   | Open-Meteo                 | OpenWeatherMap            | Cost                          | 100% free, no API key, no signup, no rate limits                         |
| **Observability** | CloudWatch Dashboard (IaC) | Manual Console dashboards | Operational Excellence        | Version-controlled, reproducible, ships with every deployment            |

```
| SRH Leipzig University | 2026
