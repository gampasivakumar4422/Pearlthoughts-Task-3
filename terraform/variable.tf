variable "aws_region" {
    type = string
}
variable "key_name" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "ami" {
    type = string
}
variable "vpc_security_group_id" {
    type = string
}
variable "subnet_id" {
    type = list
}
variable "vpc_id" {
    type = string
}

