provider "aws" {
  region = "ap-south-1"
}


resource "aws_s3_bucket" "resume_bucket" {
  bucket = "resume908"
}


resource "aws_s3_bucket_website_configuration" "resume_hosting" {
  bucket = aws_s3_bucket.resume_bucket.id

  index_document {
    suffix = "index.html"
  }
}



resource "aws_s3_object" "index_file" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "index.html"
  source       = "index.html"  
  content_type = "text/html"  
  etag         = filemd5("index.html")
}

resource "aws_s3_bucket_policy" "secure_policy" {
  bucket = aws_s3_bucket.resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.resume_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.resume_cdn.arn
          }
        }
      }
    ]
  })
}

resource "aws_dynamodb_table_item" "item_one" {
  table_name = aws_dynamodb_table.resume.name
  
  hash_key   = aws_dynamodb_table.resume.hash_key

  item = jsonencode({
    "id": {"S": "1"}, 
    "views": {"N": "0"} 
  })
}
