resource "aws_instance" "nginx" {
  count                   = 1
  ami                     = "ami-900be8ea"
  instance_type           = "t2.micro"
  key_name                = "mentat"
  vpc_security_group_ids  = [
    "${aws_security_group.mongoose-nginx.id}",
    "${aws_security_group.jenkins.id}",
    "${aws_security_group.mongoose-swarm.id}"
  ]
  tags {
    Name                  = "nginx-${var.environment}-${count.index + 1}"
    Environment           = "${var.environment}"
    Application           = "mongoose"
    Docker                = "master"
  }
  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = "${file("mentat.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker swarm init",
      "sudo docker swarm join-token --quiet worker > /home/ubuntu/token",
      "sudo docker node update --label-add type=nginx $(hostname)"
    ]
  }
}

resource "aws_instance" "app" {
  count                   = 1
  ami                     = "ami-900be8ea"
  instance_type           = "t2.micro"
  key_name                = "mentat"
  vpc_security_group_ids  = [
    "${aws_security_group.mongoose-app.id}",
    "${aws_security_group.jenkins.id}",
    "${aws_security_group.mongoose-swarm.id}"
  ]
  tags {
    Name                  = "app-${var.environment}-${count.index + 1}"
    Environment           = "${var.environment}"
    Application           = "mongoose"
  }
  provisioner "local-exec" {
    command = "bash join_swarm.sh ${aws_instance.nginx.public_ip} ${aws_instance.nginx.private_ip} ${aws_instance.app.public_ip} app"
  }

}

resource "aws_instance" "mongo" {
  count                   = 1
  ami                     = "ami-900be8ea"
  instance_type           = "t2.micro"
  key_name                = "mentat"
  vpc_security_group_ids  = [
    "${aws_security_group.mongoose-mongo.id}",
    "${aws_security_group.jenkins.id}",
    "${aws_security_group.mongoose-swarm.id}"
  ]
  tags {
    Name                  = "mongo-${var.environment}-${count.index + 1}"
    Environment           = "${var.environment}"
    Application           = "mongoose"
  }
  provisioner "local-exec" {
    command = "bash join_swarm.sh ${aws_instance.nginx.public_ip} ${aws_instance.nginx.private_ip} ${aws_instance.mongo.public_ip} mongo"
  }
}
