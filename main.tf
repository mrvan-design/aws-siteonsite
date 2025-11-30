##############################
# VPC + Subnet + IGW + NAT
##############################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags = { Name = "${var.project_name}-public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone = var.az
  tags = { Name = "${var.project_name}-private-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc" 
  tags = { Name = "${var.project_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags = { Name = "${var.project_name}-nat-gw" }
}

##############################
# VPN (Virtual Private Gateway, Customer Gateway, Connection)
##############################
resource "aws_vpn_gateway" "vpg" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project_name}-vpg" }
}

resource "aws_customer_gateway" "main_cgw" {
  bgp_asn    = 65000 
  ip_address = "118.70.145.178" # <-- ĐÃ THAY THẾ IP CÔNG CỘNG THỰC TẾ
  type       = "ipsec.1"
  tags = { Name = "${var.project_name}-cgw" }
}

resource "aws_vpn_connection" "site_to_site" {
  vpn_gateway_id      = aws_vpn_gateway.vpg.id
  customer_gateway_id = aws_customer_gateway.main_cgw.id
  type                = aws_customer_gateway.main_cgw.type
  static_routes_only  = true # Vẫn giữ nguyên
  
  # Đã XÓA static_routes = [var.onprem_cidr]

  tags = {
    Name = "${var.project_name}-vpn-connection"
  }
}
##############################
# Route Tables and Associations
##############################
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  # ROUTE VPN: Trỏ mạng tại chỗ qua VPG
  route {
    cidr_block = var.onprem_cidr 
    gateway_id = aws_vpn_gateway.vpg.id 
  }

  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  
  # ROUTE VPN: Trỏ mạng tại chỗ qua VPG
  route {
    cidr_block = var.onprem_cidr 
    gateway_id = aws_vpn_gateway.vpg.id
  }

  tags = { Name = "${var.project_name}-private-rt" }
}
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

##############################
# Security Group (Cần điều chỉnh)
##############################
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-sg"
  description = "SG for EC2 public/private"
  vpc_id      = aws_vpc.main.id

  # CÂN NHẮC HẠN CHẾ SSH: chỉ từ mạng tại chỗ (var.onprem_cidr) hoặc IP tĩnh của bạn
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.onprem_cidr] # Đã sửa, chỉ cho phép SSH từ mạng tại chỗ
  }
  
  # HTTP từ Internet (chỉ cần thiết cho Public Subnet)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # ICMP (ping) trong VPC và Mạng tại chỗ
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr, var.onprem_cidr] # Thêm cho phép ping từ mạng tại chỗ
  }

  # Egress mở toàn bộ
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg" }
}