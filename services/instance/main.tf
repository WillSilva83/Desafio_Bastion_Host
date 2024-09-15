

module "network_main" {
  source = "../network"
}

## SECURITY GROUP - PUBLIC

resource "aws_security_group" "SG-PUBLIC" {
  vpc_id      = module.network_main.vpc_main
  description = "Acesso RDP e acesso a internet"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-PUBLIC-TO-WINDOWS"
  }
}

## SECURITY GROUP - PRIVATE

resource "aws_security_group" "SG-PRIVATE" {
  vpc_id      = module.network_main.vpc_main
  description = "Acesso apenas dentro da rede do RDP"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-PUBLIC.id]
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.SG-PUBLIC.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-PRIVATE-TO-LINUX"
  }

}

## INSTANCE WINDOWS- 

resource "aws_instance" "windows_instance" {
  ami             = "ami-061c6ecf094efbc31"
  instance_type   = "t2.micro"
  subnet_id       = module.network_main.public_subnet_a
  security_groups = [aws_security_group.SG-PUBLIC.id]

  associate_public_ip_address = true

  key_name = "WINDOWS_KEY_PAR"

  tags = {
    Name = "Windows_Instance"
  }
}

## INSTANCE LINUX 

resource "aws_instance" "linux_instance" {
  ami                         = "ami-079d43025fa6a0145"
  instance_type               = "t2.micro"
  subnet_id                   = module.network_main.private_subnet_a
  vpc_security_group_ids      = [aws_security_group.SG-PRIVATE.id]
  associate_public_ip_address = false

  tags = {
    Name = "Linux_Instance"
  }
}


## ELASTIC IP ASSOCIATION 

resource "aws_eip" "windows_eip" {
  instance = aws_instance.windows_instance.id
  domain   = "vpc"
}

resource "aws_eip_association" "eip_association" {
  instance_id   = aws_instance.windows_instance.id
  allocation_id = aws_eip.windows_eip.id

}




