resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Engagement  = var.ENGAGEMENT
    Name = "vpc-${var.ENGAGEMENT}"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mainvpc.id
  tags = {
    Engagement = var.ENGAGEMENT
    Name = "igw-${var.ENGAGEMENT}"
  }
}
resource "aws_eip" "extip" {
  associate_with_private_ip = "10.0.0.50"
  vpc = true
}
resource "aws_nat_gateway" "natgateway" {
  subnet_id = aws_subnet.public.id
  allocation_id = aws_eip.extip.id
  depends_on=[aws_internet_gateway.gw]
  tags = {
    Name="nat-${var.ENGAGEMENT}"
    Engagement=var.ENGAGEMENT
  }
}

resource "aws_subnet" "public" {
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.mainvpc.id
  availability_zone = var.vpc_az
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-${var.ENGAGEMENT}"
    Engagement = var.ENGAGEMENT
  }
}

resource "aws_subnet" "private" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.mainvpc.id

  availability_zone = var.vpc_az
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet-${var.ENGAGEMENT}"
    Engagement = var.ENGAGEMENT
  }
}
resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.mainvpc.id
  tags = {
    Name = "rt-${var.ENGAGEMENT}"
    Engagement = var.ENGAGEMENT
  }
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.mainvpc.id
  tags = {
    Name = "rt-${var.ENGAGEMENT}"
    Engagement = var.ENGAGEMENT
  }
}

resource "aws_route" "public_inet_gw" {
  route_table_id = aws_route_table.publicrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_nat_gw" {
  route_table_id = aws_route_table.privatert.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgateway.id
}

resource "aws_route_table_association" "public"{
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.privatert.id
}

resource "aws_security_group" "sg" {
  name = "terraformsg"
  vpc_id = aws_vpc.mainvpc.id
  depends_on = [aws_vpc.mainvpc]
  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Engagement = var.ENGAGEMENT
  }
}
resource "aws_redshift_subnet_group" "redshift_sgroup" {
  name = "cg-subnetgroup"
  subnet_ids = [aws_subnet.public.id]
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Engagement=var.ENGAGEMENT
  }
}

resource "aws_redshift_cluster" "main" {
  cluster_identifier = var.REDSHIFT_NAME
  vpc_security_group_ids = [aws_security_group.sg.id]
  database_name      = var.DB_NAME
  master_username    = var.REDSHIFT_USER
  master_password    = var.REDSHIFT_PASSWORD
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_sgroup.name
  skip_final_snapshot = true
  tags = {
    Engagement=var.ENGAGEMENT
  }
}