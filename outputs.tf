output "s3_bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "The unique ID of the S3 bucket."
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the S3 bucket."
}

output "s3_bucket_region" {
  value       = data.aws_region.current.name
  description = "The AWS region where the S3 bucket is deployed."
}

output "s3_logging_bucket" {
  value       = var.logging_config.enable ? aws_s3_bucket.logging[0].id : null
  description = "The ID of the S3 bucket used for logging, if logging is enabled. Null if logging is disabled."
}

output "s3_website_url" {
  value       = "http://${aws_s3_bucket_website_configuration.this.website_endpoint}"
  description = "The HTTP URL of the S3 static website. Note: HTTPS is not natively supported by S3."
}
