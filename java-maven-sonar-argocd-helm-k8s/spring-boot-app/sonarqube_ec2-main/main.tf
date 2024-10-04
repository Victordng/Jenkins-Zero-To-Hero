# Declaring the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "Sonarqube" {
  ami                    = "ami-0557a15b87f6559cf" # free tier AMI image
  instance_type          = "t2.medium"
  user_data              = file("sonar_script.sh")
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = "default-ec2-us-east-1" # Existing ssh key

  tags = {
    Name = "Sonarqube_Instance"
  }
}


resource "aws_route53_zone" "selected" {
  name         = "robofarming.link"
  #private_zone = false
}

resource "aws_route53_record" "domainName" {
  name    = "sonar"
  type    = "A"
  zone_id = aws_route53_zone.selected.zone_id
  records = [aws_instance.Sonarqube.public_ip]
  ttl     = 300
  depends_on = [
    aws_instance.Sonarqube
  ]
}