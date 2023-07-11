variable "provider_profile" {
    type = string
    default = "default"
}

variable "provider_region" {
    type = string
    default = "us-east-2"
}

variable "lambda_function_name" {
    type = string
    default = "Lambda-Container"
}

variable "lambda_function_desc" {
    type = string
    default = "Lambda function that runs a docker container"
}

variable "image_uri" {
    type = string
}