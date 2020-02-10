# AWS with Terraform

## Why?

I can code something. However, it's just a part of software development. People won't `git clone` the project and run it
locally, so we need to make our software accessible for them. Somehow.

This line of thinking lead me to DevOps side. I've decided to learn how people use modern cloud services to deploy their
software.

Obviously, the easiest solution is to setup resources manually (through AWS Console / Dashboard). There is a very good
AWS documentation. Tutorials also might be helpful. What we want from our infrastructure depends on
our software. If it's a very simple stateless one, then maybe just one EC2 is enough (or serverless for that matter).
Probably, in this case, there wouldn't be a need to have multiple environments to test things.

Is there a better approach in case of more advanced requirements?

#### Infrastructure as a Code (Terraform)

What are the benefits:
 - Simplicity and Speed (spin up an entire infrastructure using a single `terraform apply`)
 - Versioning (if you use version control system, then you may easily track changes in the infrastructure)
 - Efficiency (no need to manually click through the dashboards; copy paste code snippets used reasonably)
 - Reduced risk (if someone will destroy the infrastructure, you may always recreate it based on the code;
    be cautious with terraform execution plan destroys as it could cause downtime though)
 - Multiple environments with identical infrastructure setup (dev, staging, prod -- all almost the same)
 
Who wouldn't want to use it?

#### Why AWS?

AWS is by many considered as the most complex cloud provider. There are a lot of configurations and options.
Much less magic. In my opinion, created resources on AWS resemble the real world infrastructure, so it's also helpful
for the understanding how things work underneath. Complexity could suggest that using another cloud provider
(most likely) will be easier. Furthermore, AWS has a *Free Tier* program. It allows to learn their tools for free.

So, why not? What would be a better choice?

## What

This project has no real value. I suggest to not use my code as an example for your projects.

### Resources

Automated spinning up EC2 instance with Terraform.

There is also a separate network implementation. It may seem redundant (and it is), at least for now. I thought it would
be a good practice to separate different project resources, so that they won't interfere.

[Placeholder for the infrastructure diagram.]

#### Setup ENVs

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

#### Deploy

```
# You can use `terraform plan` to see what's going to happen.
terraform apply
```

#### Destroy

```
terraform destroy
```
