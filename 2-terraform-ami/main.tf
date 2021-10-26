data "aws_instance" "k8s" {

  filter {
    name   = "tag:Name"
    values = ["ami-k8s"]
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_ami_from_instance" "ami-k8s" {
  name               = "terraform-k8s-${var.versao}"
  source_instance_id = data.aws_instance.k8s.id
}

variable "versao" {
  type        = string
  description = "Qual versão da imagem?"
}

output "ami" {
  value = [
    "AMI: ${aws_ami_from_instance.ami-k8s.id}"
  ]
}
