
# Instance related variables

variable "instance_type" {
  description = "The instance type to be used by the ec2 instance"
  type        = string
  default       = "t3.micro"
}

variable "instance_name" {
  description = " The ec2 instance name"
  type        = string
  default       = "s3-uploader-demo"
}

# S3 related variables
variable "bucket" {
  description = "Bucket name to store artifacts"
  type        = string
  default       = "s3-uploader-321" # change to a unique name
}