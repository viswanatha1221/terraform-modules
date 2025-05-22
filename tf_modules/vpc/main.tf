# VPC
resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"

    tags = {
      Name = "my_vpc"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = var.private_subnet_names[count.index]
  }
}

resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}