terraform {
  backend "s3" {
    bucket         = "okla-terraform-state-bucket"
    key            = "client1/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}