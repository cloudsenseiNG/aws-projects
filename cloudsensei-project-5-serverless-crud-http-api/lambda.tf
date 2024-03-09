# This Terraform code creates four AWS Lambda functions 
# and their associated IAM roles, policies, and permissions.
# The four functions are create, read, update, and delete. 
# Each function has a specified S3 bucket and key for the function's 
# deployment package. All four functions are in the Python 3.10 runtime, 
# and each has an IAM role associated with it that allows access 
# to DynamoDB and CloudWatch Logs. Additionally, five Lambda permissions 
# are created to allow API Gateway to invoke each function based on specific 
# HTTP methods and paths.

resource "aws_lambda_function" "create" {
  function_name = "create"

  s3_bucket = "crud-serverless-api-bucket-tut"
  s3_key    = "v1.0.0/create.zip"

  handler = "create-function.lambda_handler"
  runtime = "python3.10"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "read" {
  function_name = "read"

  s3_bucket = "crud-serverless-api-bucket-tut"
  s3_key    = "v1.0.0/read.zip"

  handler = "read-function.lambda_handler"
  runtime = "python3.10"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "update" {
  function_name = "update"

  s3_bucket = "crud-serverless-api-bucket-tut"
  s3_key    = "v1.0.0/update.zip"

  handler = "update-function.lambda_handler"
  runtime = "python3.10"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "delete" {
  function_name = "delete"

  s3_bucket = "crud-serverless-api-bucket-tut"
  s3_key    = "v1.0.0/delete.zip"

  handler = "delete-function.lambda_handler"
  runtime = "python3.10"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "crud-api-exec-role-policy"
  role = aws_iam_role.lambda_exec.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "dynamodb:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:839399074955:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:839399074955:log-group:/aws/lambda/*:*"
            ]
        }        
      ]  
}  
EOF
}

resource "aws_iam_role" "lambda_exec" {
  name = "crud-api-exec-role"

  assume_role_policy = <<EOF
{
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
}
EOF
}

resource "aws_lambda_permission" "apigw_create" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.crud_http_api_gw.execution_arn}/*/POST/items"
}

resource "aws_lambda_permission" "apigw_read_all" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.crud_http_api_gw.execution_arn}/*/GET/items"
}

resource "aws_lambda_permission" "apigw_read_item" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.crud_http_api_gw.execution_arn}/*/GET/items/{id}"
}

resource "aws_lambda_permission" "apigw_update" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.crud_http_api_gw.execution_arn}/*/PUT/items/{id}"
}

resource "aws_lambda_permission" "apigw_delete" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.crud_http_api_gw.execution_arn}/*/DELETE/items/{id}"
}