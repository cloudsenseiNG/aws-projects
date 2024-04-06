resource "aws_dynamodb_table" "this" {
  name           = "order-table"
  billing_mode   = "PROVISIONED"
  hash_key       = "user_id"
  range_key      = "id"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "OrderTable"
  }
}
