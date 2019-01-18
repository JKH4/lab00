terraform {
  backend "s3" {
    bucket = "training-tf"
    key    = "WebApp/terraform.tfstate"
    region = "eu-west-1"

    # dynamodb_table = "training-tf-webapp"
  }
}
