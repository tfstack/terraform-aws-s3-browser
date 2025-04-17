# terraform-aws-s3-browser

A Terraform module to deploy a public S3 static website with optional logging, used as a lightweight file browser (e.g., with [aws-js-s3-explorer](https://github.com/awslabs/aws-js-s3-explorer)).

---

## 📦 Features

- Creates a public S3 bucket for static website hosting
- Uploads `index.html` and supporting files
- Enables optional access logging to a dedicated bucket
- Applies public access policy (via `allowed_principals`)
- Supports lifecycle cleanup for logs
- Outputs full access URL for easy use

---

## ✅ Usage

```hcl
module "s3_browser" {
  source = "../.."

  s3_config = {
    bucket_name          = "s3-browser"
    bucket_suffix        = random_string.suffix.result
    enable_force_destroy = true
    source_file_path     = "${path.module}/external"
    allowed_principals   = ["*"]
  }

  logging_config = {
    enable               = true
    enable_encryption    = true
    encryption_algorithm = "AES256"
    log_retention_days   = 30
    s3_prefix            = "s3/"
  }

  tags = {
    Name = "s3-browser-${random_string.suffix.result}"
  }
}
