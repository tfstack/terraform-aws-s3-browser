############################################
# DATA & LOCALS
############################################
data "aws_region" "current" {}

locals {
  s3_bucket_name = (
    var.s3_config.bucket_suffix == "" ?
    var.s3_config.bucket_name :
    "${var.s3_config.bucket_name}-${var.s3_config.bucket_suffix}"
  )
}

############################################
# S3 BUCKET CONFIGURATION
############################################
resource "aws_s3_bucket" "this" {
  bucket        = local.s3_bucket_name
  force_destroy = var.s3_config.enable_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.s3_config.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.s3_config.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.s3_config.public_access.block_public_acls
  block_public_policy     = var.s3_config.public_access.block_public_policy
  ignore_public_acls      = var.s3_config.public_access.ignore_public_acls
  restrict_public_buckets = var.s3_config.public_access.restrict_public_buckets
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = var.s3_config.bucket_acl

  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]
}

############################################
# STATIC WEBSITE HOSTING
############################################
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.s3_config.index_document
  }

  dynamic "error_document" {
    for_each = var.s3_config.error_document != "" ? [var.s3_config.error_document] : []
    content {
      key = var.s3_config.error_document
    }
  }
}

############################################
# BUCKET POLICY & CORS
############################################
resource "aws_s3_bucket_policy" "this" {
  count = var.s3_config.public_access.block_public_policy == false ? 1 : 0

  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListAndGet",
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetObject"],
        Resource = [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"],
        Principal = {
          AWS = join(",", var.s3_config.allowed_principals)
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_acl.this
  ]
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "x-amz-meta-custom-header"]
  }
}

############################################
# STATIC CONTENT UPLOADS
############################################
data "template_file" "index" {
  template = file("${path.module}/external/index.html.tpl")
  vars = {
    bucket_name = local.s3_bucket_name
    region      = data.aws_region.current.name
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  content      = data.template_file.index.rendered
  content_type = "text/html"
}

resource "aws_s3_object" "this" {
  for_each = fileset(var.s3_config.source_file_path, "**/*")

  bucket = aws_s3_bucket.this.id
  key    = each.value
  source = "${var.s3_config.source_file_path}/${each.value}"

  content_type = lookup({
    ".avi"   = "video/x-msvideo",
    ".css"   = "text/css",
    ".csv"   = "text/csv",
    ".eot"   = "application/vnd.ms-fontobject",
    ".gif"   = "image/gif",
    ".gz"    = "application/gzip",
    ".html"  = "text/html",
    ".jpeg"  = "image/jpeg",
    ".jpg"   = "image/jpeg",
    ".js"    = "application/javascript",
    ".json"  = "application/json",
    ".mp3"   = "audio/mpeg",
    ".mp4"   = "video/mp4",
    ".ogg"   = "audio/ogg",
    ".pdf"   = "application/pdf",
    ".png"   = "image/png",
    ".svg"   = "image/svg+xml",
    ".tar"   = "application/x-tar",
    ".ttf"   = "font/ttf",
    ".txt"   = "text/plain",
    ".wav"   = "audio/wav",
    ".webm"  = "video/webm",
    ".woff"  = "font/woff",
    ".woff2" = "font/woff2",
    ".xml"   = "application/xml",
    ".zip"   = "application/zip"
  }, regex("\\.[^.]+$", each.value), "application/octet-stream")
}

############################################
# LOGGING CONFIGURATION
############################################
resource "aws_s3_bucket" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket        = "${local.s3_bucket_name}-logs"
  force_destroy = var.s3_config.enable_force_destroy

  tags = merge(var.tags, { Name = "${local.s3_bucket_name}-logs" })
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket = aws_s3_bucket.logging[0].id

  rule {
    object_ownership = var.s3_config.object_ownership
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  count = var.logging_config.enable && var.logging_config.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.logging[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.logging_config.encryption_algorithm
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket = aws_s3_bucket.logging[0].id

  rule {
    id     = "log-retention"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.logging_config.log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.logging_config.log_retention_days
    }
  }
}

resource "aws_s3_bucket_logging" "logging" {
  count = var.logging_config.enable ? 1 : 0

  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.logging[0].id
  target_prefix = var.logging_config.s3_prefix

  depends_on = [
    aws_s3_bucket.logging
  ]
}
