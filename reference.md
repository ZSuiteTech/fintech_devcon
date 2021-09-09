[< readme](README.md)

# Basic Concepts


# Terraform
1. HCL - Hashicorp configuration language
    1. Example
    ```terraform
    resource "aws_vpc" "main" {
      cidr_block = var.base_cidr_block
    }

    <BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
    # Block body
    <IDENTIFIER> = <EXPRESSION> # Argument
    }
    ```
1. Resources
   1. describe one or more infrastructure objects
   1. resources are declared with a resource block
   1. resources define behavior so that they can be
      1. created
      1. destroyed
      1. updated in place
      1. destroyed and recreated
1. Datasources
   1. special type of read only `resource`
   1. used to retrieve data for resources that already exist
   1. requested using block
1. Providers
   1. plugins that define how to interact with a cloud provider, saas provider or any api
   1. includes a set of `resources` and `datasources`
   1. providers are typically found and managed in the [Terraform Registry](https://registry.terraform.io/browse/providers)
1. Variables
   1. Input - used as parameters for a module
   1. Output - returned values from a module
   1. local - convenience to name an expression
1. Modules
   1. containers for multiple resources
   1. types
      1. root module - ex: this `main.tf`
      1. child module
         1. a module called by another module
         1. can be defined locally
         1. can be called multiple times
         1. ex: argocd module
      1. published module
         1. remote module
         1. can be found in Terraform Registry
         1. could be third party/opensource        
1. State
   1. a file created by terraform to track managed infrastructure
   1. stores identifiers and metadata needed to link infrastructure to resources
   1. the state is refreshed against actual infrastructure before configurations are applied
   1. state can be stored locally or remotely
      1. s3 is a recommended remote store to enable state to be shared
      1. state can contain sensitive data
