variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "raj-private"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "bedrock-demo"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "BedrockDemo"
    ManagedBy   = "Terraform"
  }
}
