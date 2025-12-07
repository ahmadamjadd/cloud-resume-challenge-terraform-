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


resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.resume_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_s3_object" "index_file" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "index.html"
  source       = "index.html"  # Path to file on your laptop
  content_type = "text/html"   # Crucial! Otherwise browser downloads it instead of showing it
}


output "website_url" {
  value = aws_s3_bucket_website_configuration.resume_hosting.website_endpoint
}