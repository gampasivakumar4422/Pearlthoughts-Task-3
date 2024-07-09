
provider "aws" { 
 region = "us-west-2" 
} 
resource "aws_key_pair" "test" { 
 key_name = var.key_name 
 public_key = file("./demo.pub") 
} 
resource "aws_instance" "web" { 
 ami = var.ami 
 instance_type = var.instance_type 
 subnet_id = var.subnet_id[0]
 key_name = aws_key_pair.test.key_name 
 vpc_security_group_ids =[var.vpc_security_group_id]
 tags = { 
 Name = "StrapiServer"
 } 
 connection {
 type = "ssh" 
 user = "ubuntu" 
 private_key = file("./demo")  
 host = self.public_ip 
 timeout = "1m" 
 agent = false 
 } 
  provisioner "remote-exec" {
  inline = [
       "sudo apt update",
      "curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -",
      "sudo apt install -y nodejs npm",
      "sudo npm install -g pm2",
      "git clone https://github.com/Pramod858/simple-strapi.git",
      "cd simple-strapi",
      " npm install",
      " chmod +x generate_env_var.sh",
      "./generate_env_var.sh",
      "npm run build",  
      "pm2 start npm --name simple-strapi -- run develop"
  ]
}
}
