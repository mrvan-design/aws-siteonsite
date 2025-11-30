output "vpc_id" {
  description = "ID của Virtual Private Cloud (VPC)"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID của Public Subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID của Private Subnet"
  value       = aws_subnet.private.id
}

output "nat_gateway_id" {
  description = "ID của NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_public_ip" {
  description = "Địa chỉ IP công cộng tĩnh của NAT Gateway (để kiểm tra lưu lượng đi ra)"
  value       = aws_eip.nat_eip.public_ip
}

output "vpn_connection_id" {
  description = "ID của kết nối Site-to-Site VPN"
  value       = aws_vpn_connection.site_to_site.id
}

output "vpn_gateway_id" {
  description = "ID của Virtual Private Gateway (VPG)"
  value       = aws_vpn_gateway.vpg.id
}

output "customer_gateway_ip" {
  description = "Địa chỉ IP công cộng của Customer Gateway (mạng tại chỗ)"
  value       = aws_customer_gateway.main_cgw.ip_address
}
# tunnel

output "tunnel1_ip_aws" {
  description = "Địa chỉ IP phía AWS cho Tunnel 1 (để cấu hình thiết bị tại chỗ)"
  value       = aws_vpn_connection.site_to_site.tunnel1_address
  #sensitive   = true
}

output "tunnel1_preshared_key" {
  description = "Khóa chia sẻ trước (PSK) cho Tunnel 1"
  value       = aws_vpn_connection.site_to_site.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel2_ip_aws" {
  description = "Địa chỉ IP phía AWS cho Tunnel 2 (để cấu hình thiết bị tại chỗ)"
  value       = aws_vpn_connection.site_to_site.tunnel2_address
  #sensitive   = true
}

output "tunnel2_preshared_key" {
  description = "Khóa chia sẻ trước (PSK) cho Tunnel 2"
  value       = aws_vpn_connection.site_to_site.tunnel2_preshared_key
  sensitive   = true
}