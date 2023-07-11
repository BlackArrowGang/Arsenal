module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.lambda_function_name
  description   = var.lambda_function_desc

  image_uri    = var.image_uri
  package_type = "Image"
  create_package = false
}