resource "aws_s3_bucket" "mongoose-images" {
  bucket                  = "mongoose-images-${var.environment}"
  acl                     = "private"
  tags {
    Name                  = "Image repository for mongoose ${var.environment}"
    Environment           = "${var.environment}"
  }
}
