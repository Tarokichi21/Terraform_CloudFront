# ---------------------------------------------
# Route53
# ---------------------------------------------
resource "aws_route53_zone" "route53_zone" {
  name          = var.domain
  force_destroy = false

  tags = merge(local.common_tags, {
    Name = "${var.domain}"
  })
}
resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.route53_zone.id
  name    = "api.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.for_webserver.dns_name
    zone_id                = aws_lb.for_webserver.zone_id
    evaluate_target_health = true
  }
}