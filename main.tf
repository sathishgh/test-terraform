/*variable "akey" {
    type = string
}
variable "skey" {
    type = string 
}*/

provider "aws" {
#    access_key = "${var.akey}"
#    secret_key = "${var.skey}"
    region="us-east-1"  
}
resource "aws_security_group" "allow_all_T" {
  name        = "allow_all_T"
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
    Name = "allow_all_T"
  }
}

resource "aws_instance" "fromjenkins" {
    ami="ami-0c02fb55956c7d316"
    key_name="terraform"
    instance_type="t2.micro" 
    vpc_security_group_ids = ["${aws_security_group.allow_all_T.id}"]
}
resource "aws_vpc" "terra-vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terra-vpc"
  }
}
resource "aws_subnet" "terra-pub" {
  vpc_id     = aws_vpc.terra-vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "terra-pub"
  }
}
resource "aws_subnet" "terra-pri" {
  vpc_id     = aws_vpc.terra-vpc.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "terra-pri"
  }
}
resource "aws_internet_gateway" "terra-gw" {
  vpc_id = aws_vpc.terra-vpc.id

  tags = {
    Name = "terra-gw"
  }
}
resource "aws_eip" "terra-lb" {
  vpc      = true
}
resource "aws_nat_gateway" "terra-ngw" {
  allocation_id = aws_eip.terra-lb.id
  subnet_id     = aws_subnet.terra-pub.id

  tags = {
    Name = "terra-ngw"
  }

}
resource "aws_route_table" "terra-rt" {
  vpc_id = aws_vpc.terra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra-gw.id
  }

  tags = {
    Name = "custom"
  }
}
resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.terra-pri.id
  route_table_id = aws_route_table.terra-rt.id
}
resource "aws_route_table" "terra-rt1" {
  vpc_id = aws_vpc.terra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terra-ngw.id
  }

  tags = {
    Name = "main"
  }
}
resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.terra-pub.id
  route_table_id = aws_route_table.terra-rt1.id
}