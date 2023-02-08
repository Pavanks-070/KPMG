provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "terraform-instance" {
  ami = "ami-072bfb8ae2c884cc4"
  instance_type = "t2.micro"
  key_name = "KEYPAIR-OCT2022"
  tags = {
    Name = "First-ec2-Instance"
  }
  availability_zone = "ap-northeast-1a"