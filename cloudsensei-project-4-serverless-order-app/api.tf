resource "aws_apigatewayv2_api" "api" {
  name          = var.api_name
  protocol_type = var.protocol_type
  cors_configuration {
    allow_methods = var.allow_methods
    allow_headers = var.allow_headers
    allow_origins = var.allow_origins
    max_age       = var.max_age
  }
  body = file("api.yaml")
}

resource "aws_apigatewayv2_authorizer" "CognitoAuthorizer" {
  api_id          = aws_apigatewayv2_api.api.id
  name            = var.auth_name
  authorizer_type = var.authorizer_type
  jwt_configuration {
    audience = [aws_cognito_user_pool.OrderCognitoPool.id]
  }
}

resource "aws_apigatewayv2_integration" "this" {
  count                  = length(var.route_key) >= 4 ? 4 : 0
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = var.integration_type
  integration_method     = var.integration_method
  connection_type        = var.connection_type
  integration_uri        = ""
  passthrough_behavior   = var.passthrough_behavior
  payload_format_version = var.payload_format_version
}

resource "aws_apigatewayv2_route" "this" {
  count     = length(var.route_key)
  api_id    = aws_apigatewayv2_api.api.id
  route_key = var.route_key[count.index]
  target    = "integrations/${aws_apigatewayv2_integration.this[count.index].id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  auto_deploy = true
  name        = "$default"
}

resource "aws_apigatewayv2_integration" "api_integration" {
  count = ""  
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.delete.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}
