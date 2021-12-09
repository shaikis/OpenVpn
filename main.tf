# Declare backend.
provider "aws" {
  region  = "${var.region}"
  profile = "${var.aws_profile}"
}

terraform {
  backend "s3" {
    bucket = "ismail-tio-test"
    key    = "vpc/openvpn/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "OpenVpnkeypair" {
    source    = "git@github.com:shaikis/terraform-aws-keypair.git"
    key_name  = "openvpn"
    pub_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFh7rDq53ubDT/w9d8ZbKrILaBe12vemvhzrcEY0UDZRjjxLaq2YfXmwR9afJ1MjwI16gENlFhmgE734lwi3xtG26/Rn9uP5wAaBjadsKj+j4F1X7g6jYb7CgcuKKvsSp+5VV1iMD+he0IoX/7J58R0X44LOOs01KWXaUhsDmmrWZF9hCtObO76XcQlYnhlkOvFxS5les1XfS7vHHGBt6umpSayWrWICNugwddLHDBeZUIYNzZu8Sky1TsO1jLokSmAc6C1AidhJY8F4qIS4jzh/yXhFNYMUmRHoO42AsJ8UjI4i2HX3HgEB3JzeUn8l4ZWLqSzf9ivaN4eLSCtkISV+vqUqui8DEL1xa/ErAoZlMeYozabolZXO9M3R+imN4dtRsubYo3MJpUMXMDFa4TglYth850rGAkTY9D0/ARXi5SIjXWy9tJGGXdgYq56SUjWwIVa+0Yrj1gkrXU+czRzQ/eYd1+KBssG8alRCdYHn/pKGlLdplSjg9qdyj2VIM= shaik@LAPTOP-0Q9MESUP" # if this value is null , it will generate new key
}

module "vpc" {
    source                    = "git@github.com:shaikis/terraform-aws-vpc.git"
    main_cidr                 = "10.0.0.0/16"
    private_subnet_cidr       = "10.0.16.0/20"
    pub_subnet_cidr           = "10.0.0.0/20"
    #Vpc tags
    vpc_name                  = "eht-vpc"
    vpc_environment_tag       = "dev"
    vpc_product_tag           = "test"
    vpc_contact_tag           = "shaik.urs@gmail.com"
    
}

module "OpenVpn" {
    source = "git@github.com:shaikis/terraform-aws-OpenVpn.git"
    vpc_id                       = module.vpc.vpc_id
    image_type_name              =  "amzn2-ami-hvm*"
    sg_name                      = "openvpn-sg"
    ebs_vol_type                 =  "gp2"
    ec2_instance_type            = "t2.nano"
    pub_subnet_id                = module.vpc.pub_subnet_id
    env_prefix_name              = "dev"
    region                       = "eu-west-1"
    keypair_arn                  = module.OpenVpnkeypair.keypair_arn
    key_name                 = module.OpenVpnkeypair.keypair.name

}
