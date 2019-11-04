# certificates
resource "aws_acm_certificate" "default" {
  for_each          = var.network_route53_zone_id
  domain_name       = "${var.service_config[each.key].name}.${var.aws_route53_root_zone_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  for_each = var.network_route53_zone_id
  name     = aws_acm_certificate.default[each.key].domain_validation_options[0].resource_record_name
  type     = aws_acm_certificate.default[each.key].domain_validation_options[0].resource_record_type
  zone_id  = var.network_route53_zone_id[each.key].id
  records  = [aws_acm_certificate.default[each.key].domain_validation_options[0].resource_record_value]
  ttl      = "60"
}

resource "aws_acm_certificate_validation" "default" {
  for_each        = var.network_route53_zone_id
  certificate_arn = aws_acm_certificate.default[each.key].arn
  validation_record_fqdns = [
    aws_route53_record.validation[each.key].fqdn,
  ]
}
