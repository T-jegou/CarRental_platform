variable "AWS_ACCESS_KEY_ID" {
  type    = string
  default = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  type    = string
  default = ""
}

variable "ATLAS_MONGO_DATABASE" {
  type    = string
  default = ""
}

variable "ATLAS_MONGO_PASSWORD" {
  type    = string
  default = ""
}

variable "ATLAS_MONGO_USERNAME" {
  type    = string
  default = ""
}

variable "ATLAS_MONGO_HOST" {
  type    = string
  default = ""
}

# arn image for ECR with default tag
variable "ECR_ARN" {
  type    = string
  default = "560022977783.dkr.ecr.eu-west-1.amazonaws.com/car_platform_repository:latest"
}
