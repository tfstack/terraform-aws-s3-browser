run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "setup_s3_static_website" {
  variables {
    s3_config = {
      bucket_name          = "test-s3-browser"
      bucket_suffix        = run.setup.suffix
      enable_force_destroy = true
      allowed_principals   = ["*"]
    }

    tags = {
      Name = "test-s3-static-site-${run.setup.suffix}"
    }
  }

  assert {
    condition     = aws_s3_bucket_acl.this.acl == "private"
    error_message = "S3 bucket ACL is not set to 'private'"
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership == "ObjectWriter"
    error_message = "Object ownership is not set to 'ObjectWriter'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Block public acls is not set to 'false'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == false
    error_message = "Block public policy is not set to 'false'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == false
    error_message = "Ignore public acls is not set to 'false'"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == false
    error_message = "Restrict public buckets is not set to 'false'"
  }
}
