## -----------------------------------------------------------------------------
## Make targets to test Terraform deployments locally.
## -----------------------------------------------------------------------------

# Global variables with a default value. Override as needed when invoking make.

# Static variables.
TF_PLAN_FILEPATH=plan.tfplan
TF_PROJECT_ROOT=$(shell pwd)

# Avoid name collisions between targets and files.
.PHONY: help fmt init validate plan apply plan-destroy destroy clean

# A target to format and present all supported targets with their descriptions.
help : Makefile
		@sed -n 's/^##//p' $<

## fmt			: Run terraform fmt.
fmt:
	terraform fmt -check=true -diff

## init 			: Run terraform init.
init:
	terraform init

## validate 		: Run terraform validate.
validate:
	terraform validate

## plan 			: Run terraform plan.
plan: fmt init validate
	terraform plan -no-color -out=${TF_PLAN_FILEPATH}

## apply 			: Run terraform apply.
apply:
	terraform apply -auto-approve -input=false

## plan-destroy 		: Run terraform plan destroy.
plan-destroy:
	terraform plan -destroy -out=${TF_PLAN_FILEPATH}

## destroy 		: Run terraform destroy.
destroy:
	terraform destroy -auto-approve

## clean			: Find and remove all the temporary files.
clean:
	@find . -name ".terraform" -type d -print0 | xargs -0 -I {} rm -rf "{}"
	@find . -name ".terraform.lock.hcl" -type f -print0 | xargs -0 -I {} rm -rf "{}"
	@find . -name "plan.tfplan" -type f -print0 | xargs -0 -I {} rm -rf "{}"