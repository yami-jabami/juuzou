variable "env" {
  type    = string
  default = ""
}

variable "hosted_zone_id" {
  default = ""
}

variable "domain_name" {
  default = ""
}

variable "db_instance_class" {
  type    = string
  default = ""
}

variable "ssh_key" {
  type    = string
  default = ""
}

variable "cassia_instance_type" {
  type    = string
  default = ""
}

variable "core_name" {
  type    = string
  default = ""
}

variable "aws_s3_bucket" {
  type    = string
  default = "bombardir_for_ukraine"
}
