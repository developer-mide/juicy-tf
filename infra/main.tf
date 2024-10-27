resource "aws_apigatewayv2_api" "version_events_webhook" {
  name          = "packer-events-webhook"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "version_events_webhook" {
  api_id     = aws_apigatewayv2_api.version_events_webhook.id
  route_key = "POST /packer-events-webhook"
  target    = "integrations/${aws_apigatewayv2_integration.version_events_webhook.id}"
}

resource "aws_apigatewayv2_stage" "version_events_webhook" {
  api_id      = aws_apigatewayv2_api.version_events_webhook.id
  name        = "packer-events-webhook"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.version_events_webhook.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "version_events_webhook" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.version_events_webhook.name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_integration" "version_events_webhook" {
  api_id             = aws_apigatewayv2_api.version_events_webhook.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

  integration_uri = aws_lambda_function.version_events_webhook.invoke_arn
}

resource "aws_lambda_permission" "version_events_webhook" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.version_events_webhook.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.version_events_webhook.execution_arn}/*/*"
}

resource "aws_iam_role" "version_events_webhook" {
  name = "packer-events-webhook"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Sid": "",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "version_events_webhook" {
  role       = aws_iam_role.version_events_webhook.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "version_events_webhook_logs" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "version_events_webhook_logs" {
  name = "packer-events-webhook-logs"

  roles      = [aws_iam_role.version_events_webhook.name]
  policy_arn = aws_iam_policy.version_events_webhook_logs.arn
}