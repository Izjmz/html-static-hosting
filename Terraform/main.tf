provider "aws" {
  region = "us-east-1" # Change if needed
}

# Security Group Creation
resource "aws_security_group" "instance_sg" {
  name        = "platform-sg"
  description = "HTML platform security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["181.194.234.5/32"] # SSH from owner's IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Public access from HTTP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Public access from HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Public outbound traffic
  }
}

# EC2 Instance Creation
resource "aws_instance" "my_instance" {
  ami                  = "ami-0083ad3f55b4cbec4" # Linux CentOS 9 Stream image
  instance_type        = "t2.micro"
  key_name             = "my-keypair" # SSH Key's name
  iam_instance_profile = "my-tf-profile"

  user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd wget java-11-openjdk git

    # Docker setup
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo docker run hello-world

    # Jenkins setup
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins
    sudo systemctl enable --now jenkins

    # Apache setup
    sudo systemctl enable --now httpd

    # Verify services status
    sudo systemctl status jenkins
    sudo systemctl status docker
    sudo systemctl status httpd

    # Welcome message
    echo "Welcome to the CentOS static hoster - izjmz"
  EOT

  security_groups = [aws_security_group.instance_sg.name] # SG link

  tags = {
    Name = "tf-iac-instance"
  }
}