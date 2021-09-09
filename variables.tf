variable "aws_region" {
    description = "default region for aws provider to use"
    type = string
    default = "us-east-1"
}
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    # {
    #   rolearn  = "arn:aws:iam::66666666666:role/role1"
    #   username = "role1"
    #   groups   = ["system:masters"]
    # },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user1"
    #   username = "user1"
    #   groups   = ["system:masters"]
    # },
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user2"
    #   username = "user2"
    #   groups   = ["system:masters"]
    # },
  ]
}

variable "vpc_suffix" {
  description = "Suffix to add to VPC name to avoid collisions"
  type = string
  default = ""
}
