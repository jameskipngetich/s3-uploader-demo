provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# Attach already created security group
data "aws_security_group" "existing" {
    id = "sg-090abd67276d3baa7"
}

# s3 Bucket module
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "s3-uploader-321" #replace with your bucket name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}

resource "aws_instance" "app_server" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  
  #attach the sg
  vpc_security_group_ids = [data.aws_security_group.existing.id]

  tags = {
    name        = "learn_tf"
    environment = "demo"
  }
}