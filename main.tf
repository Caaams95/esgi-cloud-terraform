module "ec2_instance" {
  source        = "./ec2_instance"
  my_ip         = chomp(data.http.myip.body)
  instance_name = "kungfu"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_id

}

module "s3_bucket" {
  source                        = "./s3_bucket"
  bucket_name                   = "kungfu-cams"
  very_secret_access_key_id     = module.iam.access_key_id
  very_secret_access_key_secret = module.iam.access_key_secret
  very_secret_username          = module.iam.username
}

module "iam" {
  source      = "./iam"
  username    = "kungfu"
  policy_name = "kungfu"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}

module "kms" {
  source            = "./kms"
  kungfu_user_arn   = module.iam.user_arn
}

module "network" {
  source              = "./network"
  vpc_name            = "main-vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "eu-west-3a"
}

