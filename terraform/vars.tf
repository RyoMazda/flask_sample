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
