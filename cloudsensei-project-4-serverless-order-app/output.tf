output "api_endpoint" {
  value       = aws_apigatewayv2_api.crud_http_api_gw.api_endpoint
  description = "Test API endpoint with this address"
}