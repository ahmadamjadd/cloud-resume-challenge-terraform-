# =========================================================================
# 1. THE DATABASE (DynamoDB)
# =========================================================================
resource "aws_dynamodb_table" "resume" {
  name         = "resume"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  # Fix: Only define the Key here. Do NOT define "views" or "Counter".
  attribute {
    name = "id"
    type = "S"
  }
}

# =========================================================================
# 2. THE SECURITY PASS (IAM Role)
#    This allows the Lambda to exist and talk to other services.
# =========================================================================
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  # The "Trust Policy": This allows the Lambda service to assume this role.
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

# 2a. The Permissions (What the role can actually do)
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Allow Lambda to read/write to DynamoDB and log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Database Permissions
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.resume.arn
      },
      {
        # Logging Permissions (Crucial for debugging!)
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

# Step 3a: Zip the Python code (AWS requires a zip file, not just .py)
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
  handler       = "func.lambda_handler" # File name (func) + Function name (lambda_handler)
  runtime       = "python3.13"
  
  # This detects changes in your code and re-deploys automatically
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
}

# =========================================================================
# 4. THE TRIGGER (API Gateway Permission)
#    (We will build the actual API Gateway in the next step, 
#     but this permission allows it to knock on the door).
# =========================================================================
