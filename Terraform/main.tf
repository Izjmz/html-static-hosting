provider "aws" {
  region = "us-east-1"
}

# Security Group Creation
resource "aws_security_group" "instance_sg" {
  name        = "platform-sg"
  description = "HTML platform security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["var.my_ip"] #SSH connection from admin's IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #HTTP connection
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #HTTPS connection
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_instance" {
  ami                  = "ami-0083ad3f55b4cbec4"
  instance_type        = "t2.micro"
  key_name             = "my-keypair"
  iam_instance_profile = "my-tf-profile"

  user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd wget java-11-openjdk git
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo docker run hello-world
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins
    sudo systemctl enable --now jenkins
    sudo systemctl enable --now httpd
    sudo systemctl status jenkins
    sudo systemctl status docker
    sudo systemctl status httpd
    echo "Welcome to the CentOS static hoster - izjmz"
  EOT

  security_groups = [aws_security_group.instance_sg.name] # SG link

  tags = {
    Name = "tf-iac-instance"
  }
}