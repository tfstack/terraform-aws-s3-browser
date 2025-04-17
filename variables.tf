variable "s3_config" {
  description = "Configuration for the S3 bucket, including naming, access controls, and website settings."
  type = object({
    bucket_name          = optional(string, "s3-static-site")
    bucket_acl           = optional(string, "private")
    bucket_suffix        = optional(string, "")
    enable_force_destroy = optional(bool, false)
    object_ownership     = optional(string, "ObjectWriter")
    enable_versioning    = optional(bool, false)
    index_document       = optional(string, "index.html")
    error_document       = optional(string, "")
    public_access = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, false)
      ignore_public_acls      = optional(bool, false)
      restrict_public_buckets = optional(bool, false)
      }), {
      block_public_acls       = true
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
    })
    source_file_path   = optional(string, "/var/www")
    allowed_principals = optional(list(string), ["*"])
  })

  validation {
    condition     = can(regex("^[a-z0-9-]{3,47}$", var.s3_config.bucket_name)) && (length(var.s3_config.bucket_name) + length(var.s3_config.bucket_suffix) <= 63)
    error_message = "The bucket name must be DNS-compliant: lowercase letters, numbers, and hyphens only, and its combined length with the suffix must not exceed 63 characters."
  }

  validation {
    condition     = contains(["private", "public-read"], var.s3_config.bucket_acl)
    error_message = "The bucket ACL must be either 'private' or 'public-read'."
  }

  validation {
    condition     = length(var.s3_config.bucket_suffix) <= 16
    error_message = "The bucket suffix must be 16 characters or fewer."
  }

  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.s3_config.object_ownership)
    error_message = "The object ownership setting must be one of 'BucketOwnerPreferred', 'ObjectWriter', or 'BucketOwnerEnforced'."
  }

  validation {
    condition     = length(var.s3_config.index_document) > 0
    error_message = "The index document name cannot be empty."
  }

  validation {
    condition     = length(var.s3_config.source_file_path) > 0
    error_message = "The source file path cannot be empty."
  }

  validation {
    condition     = length(var.s3_config.allowed_principals) > 0
    error_message = "At least one allowed principal must be specified."
  }
}

variable "logging_config" {
  description = "Configuration for S3 bucket logging."
  type = object({
    enable               = bool
    s3_prefix            = optional(string, "s3/")
    log_retention_days   = optional(number, 30)
    enable_encryption    = optional(bool, true)
    encryption_algorithm = optional(string, "AES256")
  })
  default = {
    enable               = false
    s3_prefix            = "s3/"
    log_retention_days   = 90
    enable_encryption    = true
    encryption_algorithm = "AES256"
  }

  validation {
    condition = (
      var.logging_config.enable == false ||
      (var.logging_config.enable == true && length(var.logging_config.s3_prefix) > 0)
    )
    error_message = "If logging is enabled, s3_prefix must be a non-empty string."
  }

  validation {
    condition     = var.logging_config.s3_prefix == "" || can(regex("^[a-zA-Z0-9!_.*/-]+$", var.logging_config.s3_prefix))
    error_message = "The s3_prefix must be a valid string containing only alphanumeric characters, hyphens, underscores, slashes, or dots."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources. Tags are useful for identifying and managing resources in AWS. If no tags are provided, an empty map will be used."
  type        = map(string)
  default     = {}
}
