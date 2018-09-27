provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "${var.AWS_REGION}"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-flask-sample"
    key    = "pigimaru/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
