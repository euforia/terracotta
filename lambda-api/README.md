# AWS Lambda, API Gateway

This implements a Lambda and API Gateway pattern.

### Architecture

This module registers a lambda to a given path on an existing api gateway.

```
API Gateway /path --> lambda
```

### Pre-requisites

The following pre-requisites are required:

- Existing API Gateway

### Usage

```hcl
module "lambda-api" {
    lambda_filepath = "../function.zip"
    lambda_name     = "MyName"
    apigateway_id   = "r4k51ldkji"
    endpoint        = "POST /my_endpoint"
}
```

The default configuration uses the `Golang` runtime, `x86_64` architecture.