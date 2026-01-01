variable "retained_image_count" {
  default     = 5
  type        = number
  description = "The maximum number of images to retain in the repository"
}

variable "repo_name" {
  type        = string
  description = "The name of the ECR repository."
}

variable "push_principal_access" {
  type        = list(string)
  description = "The AWS Principals that have permissions to push images to this repository. eg: User/Role"
}

variable "tag_mutability" {
  type        = string
  description = "The immutability of the images published to ECR"
  default     = "IMMUTABLE"
}

variable "enable_organization_access" {
  description = "Whether to allow access from AWS Organization members. If false, limits access to current account only"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the ECR."
  type        = map(string)
  default     = {}
}