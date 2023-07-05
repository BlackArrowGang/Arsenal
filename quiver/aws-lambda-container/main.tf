locals {
  profile = "default"
  region  = "us-east-2"

  function_name = "Lambda-Container"
  function_desc = "Lambda function that runs a docker container"

  image_uri = "<image-uri>"
}

provider "aws" {
  profile = local.profile
  region  = local.region
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.function_name
  description   = local.function_desc


  image_uri    = local.image_uri
  package_type = "Image"
  create_package = false
}