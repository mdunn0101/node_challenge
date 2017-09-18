resource "aws_route53_record" "www" {
  zone_id                 = "Z1GW92OLCU2HYO"
  name                    = "mongoose-${var.environment}.azabu-juban.com"
  type                    = "A"
  ttl                     = "300"
  records                 = ["${aws_instance.nginx.public_ip}"]
}
