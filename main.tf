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

#### Network configuration
resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name        = "demo_vpc"
    environment = "demo"
  }
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Act as a firewall to the demo server"
  vpc_id      = aws_vpc.demo.id

  tags = {
    name = "demo-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow-all-ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" #semantically same as all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow-ipv4-ssh" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = "22"
  ip_protocol       = "ssh"
  to_port           = "22"
}

# Attach already created security group
data "aws_security_group" "existing" {
  id = "sg-090abd67276d3baa7" # Replace with your already created security group id
}


# Search for existing key pair
data "aws_key_pair" "existing" {
  key_name = "lelkey" #replace with your keypair name
}
### You can create your own key pair by commenting out the code block above and uncommenting the one below
### Warning Generating ssh key_pairs in terraform is a security risk if state backend are not managed in a secure isolated environment


# search for s3 execution iam role
data "aws_iam_instance_profile" "existing" {
  name = "EC2-S3-Access-Role"
}

# s3 Bucket module
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.bucket
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  force_destroy = true
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  

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
    name        = var.instance_name
    environment = "demo"
  }
}


