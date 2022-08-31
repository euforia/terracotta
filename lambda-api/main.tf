data "aws_apigatewayv2_api" "apigw" {
  api_id = var.apigateway_id
}

resource "aws_lambda_function" "lambda" {
  filename         = var.lambda_filepath
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(var.lambda_filepath)
  handler          = var.lambda_handler_name
  architectures    = [var.lambda_arch]
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow"
        Sid    = "${var.lambda_name}LambdaAssumeRole"
      }
    ]
  })
}

// Cloudwatch logging
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_name}_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      }
    ]
  })
}

// Attach policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


// Allow api gateway to invoke it.
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${data.aws_apigatewayv2_api.apigw.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = var.apigateway_id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "apigateway_route" {
  api_id    = var.apigateway_id
  route_key = var.endpoint
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}
