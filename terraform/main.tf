provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow inbound traffic for Strapi"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_instance" "strapi" {
  ami           = "ami-0604d81f2fd264c7b" 
  instance_type = "t2.medium"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.strapi_sg.name]

   provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -",
      "sudo yum install -y nodejs git",
      "sudo npm install -g pm2",
      "sudo mkdir -p /srv/strapi",
      "sudo chown ec2-user:ec2-user /srv/strapi"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "cd /srv/strapi",
      "git clone https://github.com/gampasivakumar4422/strapi-app.git . || (cd strapi-app && git pull origin main)",
      "ls -l /srv/strapi", # Debug step to list files in /srv/strapi
      "cat /srv/strapi/package.json || echo 'package.json not found'", # Debug step to check if package.json exists
      "npm install",
      "npm run build",
      "pm2 start npm --name 'strapi' -- start"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}

output "strapi_instance_ip" {
  value = aws_instance.strapi.public_ip
}
