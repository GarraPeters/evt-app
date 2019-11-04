output "zone_id" {
  value = aws_route53_zone.host_zone
}

output "zone_name" {
  value = var.aws_route53_zone_name
}
