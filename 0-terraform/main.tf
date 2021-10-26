locals {
  vpc_id = "vpc-0735473c0650139ff"
  subnet = "*treiname*" ### Nesse campo precisaremos fazer um filtro das suas subnets, nesse casoo faremos de todas que contém priv no nome.
}

data "aws_subnet_ids" "main" {
  vpc_id = local.vpc_id
  filter {
    name   = "tag:Name"
    values = [local.subnet]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "k8s_ami" {
  ami                         = "ami-054a31f1b3bf90920"
  instance_type               = "t2.large"
  subnet_id                   = tolist(data.aws_subnet_ids.main.ids)[0]
  associate_public_ip_address = true
  key_name                    = "key_wrmeplt_v2"
  root_block_device {
    encrypted = true
  }
  tags = {
    Name = "ami-k8s"
  }
  vpc_security_group_ids = [aws_security_group.sec-k8s.id]
}

resource "aws_security_group" "sec-k8s" {
  name        = "acessos_ami"
  description = "acessos_ami inbound traffic"
  vpc_id      = data.aws_subnet_ids.main.id

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["${chomp(data.http.myip.body)}/32"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
    {
      description      = "SSH from VPC"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["${chomp(data.http.myip.body)}/32"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

}

# terraform refresh para mostrar o ssh
output "ami-k8s" {
  value = [
    "k8s_ami ",
    "id: ${aws_instance.k8s_ami.id} ",
    "private: ${aws_instance.k8s_ami.private_ip} ",
    "public: ${aws_instance.k8s_ami.public_ip} ",
    "public_dns: ${aws_instance.k8s_ami.public_dns} ",
    "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.k8s_ami.public_dns} "
  ]
}

