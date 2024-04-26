# Define API Gateway routes and integrations
locals {
  api_routes = {
    create = {
      route_key            = "POST /items",
      integration_name      = aws_lambda_function.functions["create"].function_name
    },
    read = {
      route_key            = "GET /items",
      integration_name     = aws_lambda_function.functions["read"].function_name
    },
    update = {
      route_key            = "PUT /items/{id}",
      integration_name     = aws_lambda_function.functions["update"].function_name
    },
    delete = {
      route_key            = "DELETE /items/{id}",
      integration_name      = aws_lambda_function.functions["delete"].function_name
    }
  }
}

locals {
  route = {
    read = {
      route_key            = "GET /items/{id}",
      integration_name     = aws_lambda_function.functions["read"].function_name
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "crud-http-api"
  protocol_type = "HTTP"
}


# Create API Gateway routes and integrations
resource "aws_apigatewayv2_integration" "api_integrations" {
  for_each = local.api_routes

  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.functions[each.value.integration_name].invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = local.api_routes

  api_id    = aws_apigatewayv2_api.api.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.api_integrations[each.key].id}"
}

resource "aws_apigatewayv2_route" "route" {
  for_each = local.route

  api_id = aws_apigatewayv2_api.api.id
  route_key = each.value.route_key
  target = "integrations/${aws_apigatewayv2_integration.api_integrations["read"].id}"
}

# Define and deploy API Gateway stage
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  auto_deploy = true
  name        = "$default"
}