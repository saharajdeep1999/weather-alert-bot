Group 7 : Weather Alert Bot

Cloud Solutions Capstone | SRH Leipzig University

Members : 
1. Rajdeep Saha (100005470)
2. Almaskhan Anwarkhan Kazi (100007165)

Lecturer: Kendrick Bollens
---
Project Overview
A serverless weather alert service built on AWS using Terraform. The system fetches weather data from the free Open-Meteo API every hour, computes the heat index from temperature and humidity, stores enriched records in DynamoDB, and sends email alerts via SNS when the heat index exceeds a configurable threshold stored in AWS Secrets Manager.
Architecture
```
EventBridge Scheduler (1h) → Lambda (Python 3.12) → Open-Meteo API
       ↓
  DynamoDB (store enriched data)
       ↓
  Secrets Manager (threshold check) → SNS (email alert)
       ↓
  CloudWatch (logs + alarms)
```
AWS Services Used
Service	Purpose
AWS Lambda	Serverless compute for weather fetching, heat index calculation, and alerting
Amazon EventBridge Scheduler	Hourly trigger for Lambda execution
Amazon DynamoDB	Time-series storage of enriched weather records
AWS Secrets Manager	Secure storage of heat index alert threshold (90°F)
Amazon SNS	Email notification delivery when threshold is exceeded
Amazon CloudWatch	Execution logging and error alarming
Prerequisites
AWS Learner Lab account with credentials
Terraform >= 1.5
AWS CLI configured
Git (optional, for version control)
Project Structure
```
weather-alert-bot/
├── main.tf              # Provider and backend configuration
├── variables.tf         # Input variables (AWS region, alert email)
├── lambda.tf            # Lambda function, IAM role, deployment package
├── eventbridge.tf       # EventBridge scheduler and IAM role
├── dynamodb.tf          # DynamoDB table definition
├── sns.tf               # SNS topic and email subscription
├── secretsmanager.tf    # Threshold secret storage
├── cloudwatch.tf        # Log group and metric alarm
├── outputs.tf           # Output values (ARNs, names)
└── lambda/
    └── lambda\_function.py   # Python Lambda handler
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
How It Works
EventBridge Scheduler triggers the Lambda function every hour
Lambda fetches current weather data from Open-Meteo API (Leipzig: 51.34°N, 12.37°E)
Heat Index Calculation using the NOAA formula:
```
   HI = c1 + c2\*T + c3\*RH + c4\*T\*RH + c5\*T² + c6\*RH² + c7\*T²\*RH + c8\*T\*RH² + c9\*T²\*RH²
   ```
Data Enrichment — stores temperature (°C and °F), humidity, and heat index in DynamoDB with timestamp
Threshold Check — retrieves threshold from Secrets Manager; if exceeded, publishes SNS alert
Monitoring — CloudWatch Logs capture all executions; alarm triggers on >2 errors in 5 minutes
Key Design Decisions
Decision	Chose	Rejected	Pillar	Reason
Database	DynamoDB on-demand	RDS PostgreSQL	Cost	No idle instance cost; pay-per-request fits $100 Learner Lab budget
Compute	AWS Lambda	EC2 / ECS	Cost + Operational Excellence	Serverless, no patching, free tier covers load
Weather API	Open-Meteo	OpenWeatherMap	Cost	100% free, no API key, no signup, no rate limits
Cost Estimate
Service	Monthly Cost
Lambda (1M free tier)	$0.00
DynamoDB on-demand	~$0.50
SNS Email	~$0.01
Secrets Manager	$0.40
EventBridge Scheduler	~$0.01
CloudWatch Logs	~$0.10
Total	~$1.02/month
Risk Mitigation
Risk	Mitigation
Open-Meteo API unavailable	Retry logic with 3 attempts; CloudWatch error logging
SNS email delivery delays	Best-effort acceptable for capstone demonstration
Cost overruns	All services use pay-per-use or free tier; DynamoDB on-demand prevents provisioned capacity costs
Outputs
After deployment, Terraform outputs:
`sns\_topic\_arn` — ARN of the SNS alert topic
`dynamodb\_table\_name` — Name of the weather data table
`lambda\_function\_name` — Name of the Lambda function
Cleanup
To destroy all AWS resources:
```bash
terraform destroy
```
Type `yes` when prompted.
---
Built for Cloud Solutions Capstone | SRH Leipzig University | 2026
