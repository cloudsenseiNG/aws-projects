app_instance_type = "t2.micro"

db_username = "Admin"

db_password = "PassWord1234"

backend_bucket = "terraform-state-demo-wp"

object_bucket = "wordpress-object-bucket-demo"

region = "us-east-1"

dynamodb_table = "state-lock-db"

billing_mode = "PAY_PER_REQUEST"

hash_key = "LockID"

attribute_name = "LockID"

attribute_type = "S"
