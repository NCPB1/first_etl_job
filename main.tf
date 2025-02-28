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