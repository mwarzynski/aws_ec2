# EC2

Automated spinning up EC2 instance with Terraform.

There is also a separate network implementation.
It may seem redundant (and it is), at least for now.

## Setup ENVs

AWS profile and region:

```
export AWS_REGION=eu-west-1
export AWS_PROFILE=your.profile
```

TF variables:

```
export TF_VAR_name=example-name
export TF_VAR_myip=1.2.3.4
```

## Deploy

```
# You can use `terraform plan` to see what's going to happen.
terraform apply
```

## Destroy

```
terraform destroy
```
