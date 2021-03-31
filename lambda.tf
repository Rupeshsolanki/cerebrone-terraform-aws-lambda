provider "aws" {
    region = "us-east-1"  
}

resource "aws_iam_role_policy" "lambda_policy"{
    name = "lambda_policy"
    role = aws_iam_role.lambda_role.id
    policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1617215985083",
      "Action": "logs:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

locals {
  lambda_zip_location = "outputs/hello.zip"
}

data "archive_file" "hello" {
  type        = "zip"
  source_file = "hello.py"
  output_path = "local.lambda_zip_location"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "local.lambda_zip_location"
  function_name = "hello"
  role          = aws_iam_role.lambda_role.arn
  handler       = "hello.new"  
  source_code_hash = base64sha256(local.lambda_zip_location)
  runtime = "python3.7"
}
