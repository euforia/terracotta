# AWS Lambda, API Gateway

This implements a Lambda and API Gateway pattern.

### Architecture

```
API Gateway -- /path --> lambda
```

### Usage

```hcl
module "lambda-api" {
    lambda_filepath = "../function.zip"
    lambda_name = "MyName"
    endpoint = "POST /my_endpoint"
    apigateway_id = "r4k51ldkji"
}
```
