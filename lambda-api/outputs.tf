
output "api_url" {
  value = data.aws_apigatewayv2_api.apigw.api_endpoint
}

