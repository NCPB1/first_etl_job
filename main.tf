provider "aws" {
  region = "ap-south-1"
}

# Input S3 Bucket
resource "aws_s3_bucket" "s3-input-bucket" {
  bucket = "s3-input-bucket-3-3-2025"
}

resource "aws_s3_bucket_versioning" "s3_input_versioning" {
  bucket = aws_s3_bucket.s3-input-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Output S3 Bucket
resource "aws_s3_bucket" "s3-output-bucket" {
  bucket = "s3-output-bucket-3-3-2025"
}

resource "aws_s3_bucket_versioning" "s3_output_versioning" {
  bucket = aws_s3_bucket.s3-output-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Outputs
output "input_bucket_name" {
  value = aws_s3_bucket.s3-input-bucket.bucket
}

output "output_bucket_name" {
  value = aws_s3_bucket.s3-output-bucket.bucket
}

# Lambda Permission to Allow S3 to Invoke
resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_jenkins.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3-input-bucket.arn
}

# S3 Notification to Trigger Lambda
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.s3-input-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_jenkins.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Package Lambda Function
data "archive_file" "python_zip" {
  type        = "zip"
  source_dir  = "./lambda"
  output_path = "./lambda-function.zip"
}

# Lambda Function Definition
resource "aws_lambda_function" "s3_to_jenkins" {
  function_name = "lambda-function"
  handler       = "lambda-function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda-function.zip"

  environment {
    variables = {
      JENKINS_URL       = "http://13.201.187.73:8080/" # Fixed URL
      JENKINS_USER      = "new-jenkins"
      JENKINS_API_TOKEN = "114f0ab2b6d402b177bd65dce220a4c902"
      JOB_NAME          = "First_ETL_job"
    }
  }
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# KMS Decrypt Policy for Lambda
resource "aws_iam_policy" "lambda_kms_decrypt" {
  name        = "lambda_kms_decrypt_policy"
  description = "Policy to allow Lambda to decrypt environment variables using KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ],
        Resource = "arn:aws:kms:ap-south-1:637423513260:key/114f0ab2b6d402b177bd65dce220a4c902" # Replace with your KMS key ARN
      }
    ]
  })
}

# Attach KMS Policy to Lambda Execution Role
resource "aws_iam_policy_attachment" "lambda_kms_attach" {
  name       = "lambda_kms_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = aws_iam_policy.lambda_kms_decrypt.arn
}

# Attach Basic Execution Role Policy
resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = "lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Add Permission for Lambda to Access S3
resource "aws_iam_policy_attachment" "lambda_s3_access" {
  name       = "lambda_s3_access_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}
