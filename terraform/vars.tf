/*
  初回設定
*/

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "ap-northeast-1"
}

variable "AWS_MAIN_AZ" {
  default = "ap-northeast-1a"
}

variable "AWS_SUB_AZ" {
  default = "ap-northeast-1c"
}

/*
  以下aws resourceの変数宣言
*/
# ----------
# ネットワーク
# ----------
variable "vpc_cidr" {
  default = "10.15.0.0/16"
}

variable "subnet_cidrs" {
  type = "map"

  default = {
    "public" = "10.15.1.0/24"
  }
}

# ----------
# ECS
# ----------
variable "path_to_private_key" {
  default = "mykey"
}

variable "path_to_public_key" {
  default = "mykey.pub"
}

variable "ecs_image_id" {
  type = "map"

  default = {
    ap-northeast-1 = "ami-08681de00a0aae54f"
    ap-southeast-1 = "ami-0a3f70f0255af1d29"
  }
}

variable "ecs_instance_type" {
  default = "t2.micro"
}

variable "container_name" {
  default = "fs-container"
}
