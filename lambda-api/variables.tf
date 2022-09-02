variable "lambda_filepath" {
  # default = "../dist/function.zip"
  description = "Path to lambda zip file"
}

variable "lambda_name" {
  # default = "deploy"
  description = "Name to give the lambda"
}

variable "endpoint" {
  # default = "POST /deploy"
  description = "<METHOD> <RESOURCE> the lambda maps to"
}

variable "lambda_handler_name" {
  default     = "main"
  description = "Entrypoint handler name"
}

variable "lambda_runtime" {
  default     = "go1.x"
  description = "Lambda runtime to use"
}

variable "lambda_arch" {
  default     = "x86_64"
  description = "Lambda code architecture [ 'x86_64' | 'arm64' ]"
}

variable "apigateway_id" {
  description = "API Gateway ID"
}

variable "vpc_name" {
  description = "The name of the VPC in which to create the Lambda function."
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "The name of the subnet in which to create the Lambda function."
  type        = string
  default     = ""
}

variable "create_security_group" {
  description = <<DESC
Whether the security group for the Lambda function should be created.
DESC
  type        = bool
  default     = false
}

variable "tags" {
  description = "The tags to add to a resource."
  type        = map(string)
  default     = {}
}

