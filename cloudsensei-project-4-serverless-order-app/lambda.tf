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