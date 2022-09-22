variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}
variable "db_username" {
  description = "Username for database"
  type        = string
  sensitive   = false
}
variable "db_name" {
  description = "Name for database"
  type        = string
}

variable "debug_ec2" {
  description = "Boolean variable to set the deployment of ec2"
  type = bool
  default = false
}

variable "path_to_public_key_file" {
  type = string
  default = ""
}

variable "image_name" {
  description = "Name of the Docker image to be retagged and pushed in the ECR repository"
  type = string 
}
