# =========================================================================
# 1. THE DATABASE (DynamoDB)
# =========================================================================
resource "aws_dynamodb_table" "resume" {
  name         = "resume"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# =========================================================================
# 2. THE SECURITY PASS (IAM Role)
# =========================================================================
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  # Trust Policy: Allows the Lambda service to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 2a. The Permissions (Database & Logs)
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Allow Lambda to read/write to DynamoDB and log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.resume.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 2b. Attach the permissions to the role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# =========================================================================
# 3. THE COMPUTE (Lambda Function)
# =========================================================================

# Step 3a: Zip the Python code
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/func.zip"
}

# Step 3b: Create the Function
resource "aws_lambda_function" "myfunc" {
  filename      = data.archive_file.zip_the_python_code.output_path
  function_name = "my-resume-counter"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "func.lambda_handler"
  runtime       = "python3.9" # Corrected to stable runtime
  
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
}

# =========================================================================
# 4. THE API GATEWAY (The Bridge/Trigger) 🌉
# =========================================================================

# 4a. The API Gateway (The Front Door/Base URL)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "resume-api"
  protocol_type = "HTTP"

  # CORS Configuration (Allows frontend to call the API)
  cors_configuration {
    allow_origins = ["*"] 
    allow_methods = ["POST", "OPTIONS"] # Allow POST for the counter, OPTIONS for browser check
    allow_headers = ["*"]
    max_age       = 300
  }
}

# 4b. The Integration (The Hallway: Connecting API -> Lambda)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri    = aws_lambda_function.myfunc.invoke_arn # Link by Invoke ARN
  integration_method = "POST"
  payload_format_version = "2.0"
}

# 4c. The Route (The Path: e.g., POST /)
resource "aws_apigatewayv2_route" "count_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /count" # Consistent with your last successful setup
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 4d. The Stage (The Deployment Environment)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# 4e. The Permission (The Key: Allows API Gateway to call the Lambda)
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myfunc.function_name
  principal     = "apigateway.amazonaws.com"

  # Source ARN ensures ONLY this specific API can call the function
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# =========================================================================
# 5. THE OUTPUT (For Frontend JavaScript)
# =========================================================================
output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}