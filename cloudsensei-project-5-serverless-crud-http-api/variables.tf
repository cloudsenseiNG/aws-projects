variable "source_arn" {
  type = list(string)
  default = [
      "/*/POST/items",
      "/*/GET/items",
      "/*/GET/items/{id}",
      "/*/PUT/items/{id}",
      "/*/DELETE/items/{id}"
    ]
}

variable "bucket" {
  type = string
  description = "name of lambda function bucket"
}