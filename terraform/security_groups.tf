resource "aws_security_group" "jenkins" {
  name                    = "allow_jenkins"
  description             = "Allow incoming SSH from Jenkins"
  vpc_id                  = "vpc-d24cdeab"
  ingress {
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
    cidr_blocks           = ["18.221.116.19/32", "175.177.4.76/32"]
  }
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mongoose-swarm" {
  name                    = "allow_docker"
  description             = "Allow communication between Docker hosts"
  vpc_id                  = "vpc-d24cdeab"
  ingress {
    from_port             = 2377
    to_port               = 2377
    protocol              = "tcp"
    self                  = true
  }
  ingress {
    from_port             = 7946
    to_port               = 7946
    protocol              = "tcp"
    self                  = true
  }
  ingress {
    from_port             = 7946
    to_port               = 7946
    protocol              = "udp"
    self                  = true
  }
  ingress {
    from_port             = 4789
    to_port               = 4789
    protocol              = "udp"
    self                  = true
  }
}

resource "aws_security_group" "mongoose-nginx" {
  name                    = "allow_http_from_world"
  description             = "Allow incoming http and https"
  vpc_id                  = "vpc-d24cdeab"
  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  ingress {
    from_port             = 443
    to_port               = 443
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mongoose-app" {
  name                    = "allow_from_nginx"
  description             = "Allow incoming proxied traffic from nginx"
  vpc_id                  = "vpc-d24cdeab"
  ingress {
    from_port             = 3000
    to_port               = 3000
    protocol              = "tcp"
    security_groups       = ["${aws_security_group.mongoose-nginx.id}"]
  }
}

resource "aws_security_group" "mongoose-mongo" {
  name                    = "allow_from_app"
  description             = "Allow incoming db requests from app hosts"
  vpc_id                  = "vpc-d24cdeab"
  ingress {
    from_port             = 27017
    to_port               = 27017
    protocol              = "tcp"
    security_groups       = ["${aws_security_group.mongoose-app.id}"]
  }
}
