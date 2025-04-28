module "ec2_instance" {
  source        = "./ec2_instance"
  my_ip         = chomp(data.http.myip.body)
  instance_name = "kungfu"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_id

}

module "s3_bucket" {
  depends_on                    = [module.iam]
  source                        = "./s3_bucket"
  bucket_name                   = "kungfu-cams"
  very_secret_access_key_id     = module.iam.access_key_ids["kungfu"]
  very_secret_access_key_secret = module.iam.access_key_secrets["kungfu"]
  very_secret_username          = module.iam.user_names["kungfu"]
}

module "iam" {
  source = "./iam"
  users = {
    kungfu = {
      policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      inline_policy = {
        name   = "tf-kungfu-policy"
        policy = file("iam/policies/kungfu-policy.json")
      }
      kms_keys = [
        module.kms.kungfu_key_arn
      ]
    },
    fake_admin = {
      inline_policy = {
        name   = "tf-kungfu-policy"
        policy = file("iam/policies/fake_admin-policy.json")
      }
    }
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}

module "kms" {
  source          = "./kms"
  kungfu_user_arn = module.iam.user_arn["kungfu"]
}

module "network" {
  source              = "./network"
  vpc_name            = "main-vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "eu-west-3a"
}

module "monitoring" {
  source = "./monitoring"
  vpc_id = module.network.vpc_id
}
