provider "aws" {
  region = "us-east-1"
  profile = "sathya"
}
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default = "192.168.0.0/16"
}

variable "cidr_subnet1" {
  description = "CIDR block for the subnet"
  default = "192.168.1.0/24"
}


variable "availability_zone" {
  description = "availability zone to create subnet"
  default = "us-east-1"
}
variable "environment_tag" {
  description = "Environment tag"
  default = "Production"

}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags ={
    Environment = "${var.environment_tag}"
    Name= "TerraformVpc"
  }
}

resource "aws_subnet" "subnet_public1_Lab1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr_subnet1}"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags ={
    Environment = "${var.environment_tag}"
    Name= "TerraformPublicSubnetLab1"
  }

}

resource "aws_security_group" "TerraformSG" {
  name = "TerraformSG"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags ={
    Environment = "${var.environment_tag}"
    Name= "TerraformSG"
  }

}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Terraform_IG"
  }
}
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "TerraformRouteTable"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.subnet_public1_Lab1.id}"
  route_table_id = "${aws_route_table.r.id}"
}


resource "aws_instance" "Ansible_Controller_Node" {
  ami           = "ami-0b0af3577fe5e3532"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet_public1_Lab1.id}"
  vpc_security_group_ids = ["${aws_security_group.TerraformSG.id}"]
  key_name = "sathya20"
 tags ={
    Environment = "${var.environment_tag}"
    Name= "Ansible_Controller_Node"
  }

}
resource "aws_instance" "K8S_Master_Node" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet_public1_Lab1.id}"
  vpc_security_group_ids = ["${aws_security_group.TerraformSG.id}"]
  key_name = "sathya20"
 tags ={
    Environment = "${var.environment_tag}"
    Name= "K8S_Master_Node"
  }

}
resource "aws_instance" "K8S_Slave1_Node" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet_public1_Lab1.id}"
  vpc_security_group_ids = ["${aws_security_group.TerraformSG.id}"]
  key_name = "sathya20"
 tags ={
    Environment = "${var.environment_tag}"
    Name= "K8S_Slave1_Node"
  }

}
resource "aws_instance" "K8S_Slave2_Node" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet_public1_Lab1.id}"
  vpc_security_group_ids = ["${aws_security_group.TerraformSG.id}"]
  key_name = "sathya20"
 tags ={
    Environment = "${var.environment_tag}"
    Name= "K8S_Slave2_Node"
  }

}
resource "aws_instance" "JenkinsNode" {
  ami           = "ami-0b0af3577fe5e3532"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet_public1_Lab1.id}"
  vpc_security_group_ids = ["${aws_security_group.TerraformSG.id}"]
  key_name = "sathya20"
 tags ={
    Environment = "${var.environment_tag}"
    Name= "JenkinsNode"
  }

 provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("D:/ML_Project/Clinical Lab/sathya20.pem")
      host        = aws_instance.JenkinsNode.public_ip
    }
    inline = [
      "sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y",
      "sudo yum install wget git -y",
      "sudo yum install java-1.8.0-openjdk-devel -y",
      "sudo wget O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo",
      "sudo mv /home/ec2-user/jenkins.repo   /etc/yum.repos.d/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins --now"
    ]
  }

}
