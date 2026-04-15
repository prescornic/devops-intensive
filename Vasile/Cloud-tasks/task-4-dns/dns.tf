resource "aws_route53_zone" "main" {
  name = "devops-vasile.duckdns.org"
}

resource "aws_route53_record" "app_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.devops-vasile.duckdns.org"
  type    = "CNAME"
  ttl     = 60
  
  records = [aws_instance.nginx_server.public_dns]
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}