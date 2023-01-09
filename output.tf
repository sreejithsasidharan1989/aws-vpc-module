output "vpc_id" {
  value = aws_vpc.wp_vpc.id
}

output "public_subnets" {
  value = flatten([aws_subnet.public[*].id])
}

output "private_subnets" {
  value = flatten([aws_subnet.private[*].id])
}

output "igw" {
  value = aws_internet_gateway.igw.id
}

output "natgw_id" {
  value = var.enable_natgw ? aws_nat_gateway.nat-gw[0].id : null
}

output "nat_on" {
 value = aws_route.nat_on[0].id
}
