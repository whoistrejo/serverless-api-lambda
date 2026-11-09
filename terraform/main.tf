data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["lambda.amazonaws.com"] }
  }
}
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}
resource "aws_iam_role_policy_attachment" "logs" {
  role = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
data "archive_file" "lambda" {
  type = "zip"
  source_file = "${path.module}/../app/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}
resource "aws_lambda_function" "api" {
  function_name = var.project_name
  role = aws_iam_role.lambda.arn
  handler = "lambda_function.handler"
  runtime = "python3.12"
  filename = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
}
resource "aws_apigatewayv2_api" "http" {
  name = var.project_name
  protocol_type = "HTTP"
  target = aws_lambda_function.api.arn
}
resource "aws_lambda_permission" "api" {
  statement_id = "AllowHttpApiInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
output "api_endpoint" { value = aws_apigatewayv2_api.http.api_endpoint }
