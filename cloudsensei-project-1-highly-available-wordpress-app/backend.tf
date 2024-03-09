terraform {
  backend "s3" {
    bucket         = "terraform-state-demo-wp"
    key            = "wordpress-state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "state-lock-db"
    encrypt        = true
  }
}