# resource "aws_s3_bucket" "terraform_state" {
#   bucket        = var.bucket
#   force_destroy = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
#   bucket = aws_s3_bucket.terraform_state.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_versioning" "bucket_version" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_dynamodb_table" "terraform_lock" {
#   name         = var.dynamodb_table
#   billing_mode = var.billing_mode
#   hash_key     = var.hash_key
#   attribute {
#     name = var.attribute_name
#     type = var.attribute_type
#   }
# }
