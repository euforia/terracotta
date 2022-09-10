locals {
  vpc_id          = data.aws_vpc.vpc.*.id
  name_iam_policy = "${var.lambda_name}-policy"
  name_iam_role   = "${var.lambda_name}-role"
  name_sg         = "${var.lambda_name}-sg"
}

data "aws_apigatewayv2_api" "apigw" {
  api_id = var.apigateway_id
}

data "aws_vpc" "vpc" {
  count = var.vpc_name != "" ? 1 : null
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "subnets" {
  count = var.vpc_name != "" ? 1 : null
  filter {
    name   = "vpc-id"
    values = ["${local.vpc_id[0]}"]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.*.ids[0])
  id       = each.value
}

resource "aws_security_group" "security_group" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.lambda_name}-sg"
  description = "Security Group for the ${var.lambda_name} function"
  vpc_id      = local.vpc_id[0]
  tags = merge(var.tags,
    {
      Name = local.name_sg
    },
  )
}

resource "aws_security_group_rule" "egress_all" {
  count             = var.create_security_group ? 1 : 0
  description       = "Full outbound access"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group[0].id
}

resource "aws_lambda_function" "lambda" {
  filename         = var.lambda_filepath
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda.arn
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(var.lambda_filepath)
  handler          = var.lambda_handler_name
  architectures    = [var.lambda_arch]

  dynamic "vpc_config" {
    for_each = var.vpc_name != "" && var.subnet_name != "" && var.create_security_group ? [true] : []
    content {
      security_group_ids = [aws_security_group.security_group[0].id]
      subnet_ids         = [for s in data.aws_subnet.subnet : s.id]
    }
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid    = "LambdaServiceAccess"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "AllowLoggingAccessToLambdaFunction"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "AllowEC2ENIAccess"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["arn:aws:ec2:*:*:*"]
  }
}

resource "aws_iam_role" "lambda" {
  name                 = local.name_iam_role
  description          = "A role that grants the ${local.name_iam_role} access to AWS resources."
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role.json
  max_session_duration = var.max_session_duration
  tags                 = var.tags
}

resource "aws_iam_policy" "lambda" {
  name        = local.name_iam_policy
  path        = "/"
  description = "A policy that grants the ${local.name_iam_policy} access to AWS resources."
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
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
