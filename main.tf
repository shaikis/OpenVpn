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
    image_type_name              =  "amzn2-ami-hvm*"
    ebs_vol_type                 =  gp2
    ec2_instance_type            = "t2.nano"
    pub_subnet_id                = module.vpc.pub_subnet_id
    env_prefix_name              = "dev"
    region                       = "eu-west-1"

}