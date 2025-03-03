provider "aws" {

region = "ap-south-1"

}
resource "aws_s3_bucket" "s3_input_bucket" {
    bucket = "s3_input_bucket"
 
}
resource "aws_s3_bucket_versioning" "s3_input_versioning" {
    bucket = aws_s3_bucket.s3_input_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
  
}
resource "aws_s3_bucket" "s3_output_bucket" {
    bucket = "s3_output_bucket"
  
}
resource "aws_s3_bucket_versioning" "s3_output_versioning" {
    bucket = aws_s3_bucket.s3_output_bucket.id
    versioning_configuration {
      status = "Enabled"
    }

}
output "input_bucket_name" {
    value = aws_s3_bucket.s3_input_bucket.bucket
  
}
output "output_bucket_name" {
    value = aws_s3_bucket.s3_output_bucket.bucket
  
}
resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_jenkins.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_input_bucket.arn
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.s3_input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_jenkins.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_function" "s3_to_jenkins" {
  function_name = "lambda-function"
  handler       = "lambda-function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda-function.zip"

  environment {
    variables = {
      JENKINS_URL      = "http://http://13.201.187.73:8080/"
      JENKINS_USER     = "new-jenkins"
      JENKINS_API_TOKEN = "114f0ab2b6d402b177bd65dce220a4c902"
      JOB_NAME         = "First_ETL_job"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = "lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}