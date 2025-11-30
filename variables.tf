variable "project_name" {
  description = "Tên dự án được sử dụng trong các tag tài nguyên"
  default     = "myproject"
}

variable "region" {
  description = "Vùng AWS (AWS Region) để triển khai"
  default     = "ap-southeast-1"
}

variable "az" {
  description = "Availability Zone (AZ) được sử dụng"
  default     = "ap-southeast-1a"
}

variable "vpc_cidr" {
  description = "Dải CIDR cho VPC chính"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Dải CIDR cho Public Subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Dải CIDR cho Private Subnet"
  default     = "10.0.2.0/24"
}

variable "onprem_cidr" {
  description = "Dải CIDR của mạng tại chỗ (On-Premises) để định tuyến VPN"
  default     = "10.10.0.0/16" 
}

variable "keypair" {
  description = "Tên cặp khóa SSH (Keypair) đã tồn tại trong AWS để truy cập EC2"
  type        = string
}