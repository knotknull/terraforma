##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "west_private_key_path" {}
variable "key_name" {
  default = "Terraform_key"
}
variable "key_name_west" {
  default = "Terraform_West_key"
}


##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
  alias      = "east"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-1"
  alias      = "west"
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "nginx_east" {
  provider      = "aws.east"
  ami           = "ami-c58c1dd3"
  instance_type = "t2.micro"
  key_name        = "${var.key_name}"

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }
}

resource "aws_instance" "nginx_west" {
  provider      = "aws.west"
  ami           = "ami-46e1f226"
  instance_type = "t2.micro"
  key_name        = "${var.key_name_west}"

  connection {
    user        = "ec2-user"
    private_key = "${file(var.west_private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns_east" {
    value = "${aws_instance.nginx_east.public_dns}"
}

output "aws_instance_public_dns_west" {
    value = "${aws_instance.nginx_west.public_dns}"
}
