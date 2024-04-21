# Define lambda functions and their respective configurations
locals {
  lambda_functions = {
    create = {
      function_name = "create",
      s3_key        = "v1.0.0/create.zip",
      handler       = "create-function.lambda_handler"
      source_arn    = var.source_arn[0]
    },
    read = {
      function_name = "read",
      s3_key        = "v1.0.0/read.zip",
      handler       = "read-function.lambda_handler"
      source_arn    = var.source_arn[1]
    },
    update = {
      function_name = "update",
      s3_key        = "v1.0.0/update.zip",
      handler       = "update-function.lambda_handler"
      source_arn    = var.source_arn[3]
    },
    delete = {
      function_name = "delete",
      s3_key        = "v1.0.0/delete.zip",
      handler       = "delete-function.lambda_handler"
      source_arn    = var.source_arn[4]
    }
  }
}
# Create lambda functions
resource "aws_lambda_function" "functions" {
  for_each = local.lambda_functions

  function_name = each.value.function_name
  s3_bucket     = var.bucket
  s3_key        = each.value.s3_key
  handler       = each.value.handler
  runtime       = "python3.10"
  role          = aws_iam_role.role.arn
  
}

# Define API Gateway permissions
resource "aws_lambda_permission" "apigw_permissions" {
  for_each = {
    for name, value in local.lambda_functions : name => value
  }

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}${each.value.source_arn}"

}

resource "aws_lambda_permission" "apigw_permission" {

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions["read"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}${var.source_arn[2]}"

}