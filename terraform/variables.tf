variable "aws_region" { type=string; default="eu-west-3" }
variable "project_name" { type=string; default="novaretail-migration" }
variable "environment" { type=string; default="lab" }
variable "vpc_cidr" { type=string; default="10.20.0.0/16" }
variable "db_username" { type=string; default="novaretailadmin" }
variable "db_password" {
  type=string
  sensitive=true
  validation { condition=length(var.db_password)>=12; error_message="db_password must be at least 12 characters." }
}
variable "instance_type" { type=string; default="t3.micro" }
variable "db_instance_class" { type=string; default="db.t3.micro" }
variable "enable_nat_gateway" { type=bool; default=true }
