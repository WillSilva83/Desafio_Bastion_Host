
## VPC 
resource "aws_vpc" "vpc_main" {

    cidr_block = "10.10.0.0/16"

    tags = {
      "Name" = "VPC_main" 
    }
  
}


## SUBNETS 

resource "aws_subnet" "subnet-A-public" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "sa-east-1c"
  tags = {
    Name = "SUBNET-A-PUBLIC"
  }
}

resource "aws_subnet" "subnet-A-private" {

  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "sa-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "SUBNET-A-PRIVATE"
  }

}

# INTERNET GATEWAY 

resource "aws_internet_gateway" "IGW-PUBLIC" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "IGW-PUBLIC"
  }

}

## ROUTE TABLE 

resource "aws_route_table" "RT-MAIN-PUBLIC" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW-PUBLIC.id
  }

  tags = {
    Name = "RT-MAIN-PUBLIC"
  }

}

resource "aws_route_table" "RT-MAIN-PRIVATE" {
  vpc_id = aws_vpc.vpc_main.id

  route = []

  tags = {
    Name = "RT-MAIN-PRIVATE"
  }
  
}

## ASSOCIATION 

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.subnet-A-public.id
  route_table_id = aws_route_table.RT-MAIN-PUBLIC.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.subnet-A-private.id
  route_table_id = aws_route_table.RT-MAIN-PRIVATE.id

}


## OUTPUTS 

output "private_subnet_a" {
    value = aws_subnet.subnet-A-private.id
}

output "public_subnet_a" {
  value = aws_subnet.subnet-A-public.id
  
}

output "vpc_main" {
  value = aws_vpc.vpc_main.id  
}