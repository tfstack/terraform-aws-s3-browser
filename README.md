# terraform-aws-s3-browser

Terraform module for hosting a static S3 file browser

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_object.index_html](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.index](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Configuration for S3 bucket logging. | <pre>object({<br/>    enable               = bool<br/>    s3_prefix            = optional(string, "s3/")<br/>    log_retention_days   = optional(number, 30)<br/>    enable_encryption    = optional(bool, true)<br/>    encryption_algorithm = optional(string, "AES256")<br/>  })</pre> | <pre>{<br/>  "enable": false,<br/>  "enable_encryption": true,<br/>  "encryption_algorithm": "AES256",<br/>  "log_retention_days": 90,<br/>  "s3_prefix": "s3/"<br/>}</pre> | no |
| <a name="input_s3_config"></a> [s3\_config](#input\_s3\_config) | Configuration for the S3 bucket, including naming, access controls, and website settings. | <pre>object({<br/>    bucket_name          = optional(string, "s3-static-site")<br/>    bucket_acl           = optional(string, "private")<br/>    bucket_suffix        = optional(string, "")<br/>    enable_force_destroy = optional(bool, false)<br/>    object_ownership     = optional(string, "ObjectWriter")<br/>    enable_versioning    = optional(bool, false)<br/>    index_document       = optional(string, "index.html")<br/>    error_document       = optional(string, "")<br/>    public_access = optional(object({<br/>      block_public_acls       = optional(bool, true)<br/>      block_public_policy     = optional(bool, false)<br/>      ignore_public_acls      = optional(bool, false)<br/>      restrict_public_buckets = optional(bool, false)<br/>      }), {<br/>      block_public_acls       = true<br/>      block_public_policy     = false<br/>      ignore_public_acls      = false<br/>      restrict_public_buckets = false<br/>    })<br/>    source_file_path   = optional(string, "/var/www")<br/>    allowed_principals = optional(list(string), ["*"])<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources. Tags are useful for identifying and managing resources in AWS. If no tags are provided, an empty map will be used. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The unique ID of the S3 bucket. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region where the S3 bucket is deployed. |
| <a name="output_s3_logging_bucket"></a> [s3\_logging\_bucket](#output\_s3\_logging\_bucket) | The ID of the S3 bucket used for logging, if logging is enabled. Null if logging is disabled. |
| <a name="output_s3_website_url"></a> [s3\_website\_url](#output\_s3\_website\_url) | The HTTP URL of the S3 static website. Note: HTTPS is not natively supported by S3. |
<!-- END_TF_DOCS -->
