resource "aws_route53_zone" "host_zone" {
  for_each = var.loadblancer
  name     = "${var.service_config[each.key].name}.${var.aws_route53_root_zone_name}"
}

resource "aws_route53_record" "www" {
  for_each = var.loadblancer
  zone_id  = aws_route53_zone.host_zone[each.key].zone_id
  name     = "${var.service_config[each.key].name}.${var.aws_route53_root_zone_name}"
  type     = "A"

  alias {
    name                   = var.loadblancer[each.key].dns_name
    zone_id                = var.loadblancer[each.key].zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "root_domain" {
  name = var.aws_route53_root_zone_name
}

resource "aws_route53_record" "root_ns_record" {
  for_each        = var.loadblancer
  allow_overwrite = true
  name            = "${var.service_config[each.key].name}.${var.aws_route53_root_zone_name}"
  ttl             = 30
  type            = "NS"
  zone_id         = data.aws_route53_zone.root_domain.zone_id

  records = [
    aws_route53_zone.host_zone[each.key].name_servers.0,
    aws_route53_zone.host_zone[each.key].name_servers.1,
    aws_route53_zone.host_zone[each.key].name_servers.2,
    aws_route53_zone.host_zone[each.key].name_servers.3,
  ]
}
