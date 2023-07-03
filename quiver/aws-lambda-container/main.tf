provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Lambda-Container"
  description   = "Lambda function that runs a docker container"

  create_package = false

  image_uri    = "REPLACE WITH PRIVATE ECR IMAGE URI"
  package_type = "Image"
}