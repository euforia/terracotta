# AWS Lambda, API Gateway

```hcl
module "lambda-api" {
    lambda_filepath = "../function.zip"
    lambda_name = "MyName"
    endpoint = "POST /my_endpoint"
    apigateway_id = "r4k51ldkji"
}
```