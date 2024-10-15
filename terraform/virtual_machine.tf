provider "aws" {
  region = "us-west-2"  # Set your desired AWS region
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "semi-colon-vpc"
  }
}

# Subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"  # Adjust to your region's AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "mySubnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "semi-colon-igw"
  }
}

# Route Table for Public Access
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "sg" {
  name        = "vm-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vm-sg"
  }
}

# Elastic IP
resource "aws_eip" "eip" {
  vpc = true
}

# Network Interface
resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.subnet.id
  security_groups = [aws_security_group.sg.id]

  tags = {
    Name = "myNIC"
  }
}

# EC2 Instance
resource "aws_instance" "vm" {
  ami           = "ami-083654bd07b5da81d"  # Ubuntu 18.04 AMI for us-west-2
  instance_type = "t2.micro"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic.id
  }

  key_name = "my-key"  # Ensure this key pair exists in your AWS region

  tags = {
    Name = "semi-colon-vm"
  }

  # User Data Script for Initial Setup
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > /var/www/html/index.html
  EOF
}
