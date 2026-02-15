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
  id = "sg-090abd67276d3baa7" # Replace with your already created security group id
}

# Search for existing key pair
data "aws_key_pair" "existing" {
  key_name = "lelkey" #replace with your keypair name
}

# search for s3 execution iam role
data "aws_iam_instance_profile" "existing" {
  name = "EC2-S3-Access-Role"
}

# s3 Bucket module
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "s3-uploader-321" #replace with your bucket name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  force_destroy = true
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  #attach the sg
  vpc_security_group_ids = [data.aws_security_group.existing.id]

  #attach aws_keypair
  key_name = data.aws_key_pair.existing.key_name

  # IAM role to enable interaction with s3
  iam_instance_profile = data.aws_iam_instance_profile.existing.name

  # User data,  -> install git and pip, -> install python requriemnts, -> perform a test
  user_data = <<-EOF
            #!/usr/bin/env bash
            sudo apt install -y git
            sudo apt install -y python3-pip
            git clone https://github.com/jameskipngetich/s3-uploader-demo.git 
            cd s3-uploader-demo 
            pip install requirements.txt
            EOF



  tags = {
    name        = "learn_tf"
    environment = "demo"
  }
}


