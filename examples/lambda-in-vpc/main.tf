module "lambda-api" {
  source                = "../../lambda-api"
  lambda_filepath       = "./function.zip"
  lambda_name           = "MyName"
  apigateway_id         = "r4k51ldkjh"
  endpoint              = "POST /my_endpoint"
  vpc_name              = "default"
  subnet_name           = "subnet"
  create_security_group = true
}
