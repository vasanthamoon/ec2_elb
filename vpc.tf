resource "aws_vpc" "terra_vpc" { # VPC
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "TerraVPC"
  }
}
resource "aws_internet_gateway" "terra_igw" { # Internet Gateway
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "public" { # Subnets : public
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}
#resource "aws_subnet" "public" { subnet two manual code
#  vpc_id = aws_vpc.terra_vpc.id
#  cidr_block = "10.20.2.0/24"
#  availability_zone = "us-west-2a"
#  map_public_ip_on_launch = true
#  tags = {
#    Name =subnet2
#  }
#}
resource "aws_route_table" "public_rt" {
  # Route table: attach Internet Gateway
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}
resource "aws_route_table_association" "a" { # Route table association with public subnets
  count = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}
