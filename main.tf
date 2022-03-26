variable "akey" {
    type = string
}
variable "skey" {
    type = string 
}

provider "aws" {
    access_key = "${var.akey}"
    secret_key = "${var.skey}"
    region="us-east-1"  
}
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "fromjenkins" {
    ami="ami-0c02fb55956c7d316"
    key_name="terraform"
    instance_type="t2.micro" 
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
}