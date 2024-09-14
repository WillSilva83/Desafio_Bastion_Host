

module "network_main" {
  source = "../network"
}


## SECURITY GROUP 

resource "aws_security_group" "SG-PUBLIC" {
    vpc_id = module.network_main.vpc_main
    description = "Acesso RDP e acesso a internet"

    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "SG-PUBLIC-TO-WINDOWS"
    }
}

## INSTANCE WINDOWS- 

resource "aws_instance" "windows_instance" {
    ami = "ami-061c6ecf094efbc31"
    instance_type = "t2.micro"
    subnet_id = module.network_main.private_subnet_a
    security_groups = [ aws_security_group.SG-PUBLIC.id ]

    associate_public_ip_address = true

    tags = {
      Name = "Windows_Instance"
    }  
}


## INSTANCE LINUX 


resource "aws_instance" "linux_instance" {
    ami = "ami-079d43025fa6a0145"
    instance_type = "t2.micro"
    subnet_id = module.network_main.private_subnet_a

    tags = {
      Name = "Linux_Instance"
    }
}


resource "aws_eip" "windows_eip" {
  instance = aws_instance.windows_instance.id
  domain = "vpc"
}


resource "aws_eip_association" "eip_association" {
    instance_id = aws_instance.windows_instance.id
    allocation_id = aws_eip.windows_eip.id
  
}




