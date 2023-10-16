provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_instance" "demo-server" {
    ami = "ami-067c21fb1979f0b27"
    instance_type = "t2.micro"
    key_name = "terraform"
    subnet_id = aws_subnet.demo_subnet.id
    vpc_security_group_ids = [aws_security_group.demo-vpc-sg.id]
  
}

// Create a VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.10.0.0/16"
}

// Create a Subnet
resource "aws_subnet" "demo_subnet" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo_subnet"
  }
}
// Create a internet Gateway 
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-igw"
  }
}

// Create route table 
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  tags = {
    Name = "demo-rt"
  }
}

// associate subnet with route table 
resource "aws_route_table_association" "demo-rt_association" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.demo-rt.id
}
// Create Security group

resource "aws_security_group" "demo-vpc-sg" {
  name        = "demo-vpc-sg"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "demo-vpc-sg"
  }
}

output "publicip" {

    value = aws_instance.demo-server.public_ip
  
}