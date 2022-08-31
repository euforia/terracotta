
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
