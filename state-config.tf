# backend for terraform state - s3 bucket.tf
# the s3 bucket must be created prior to running this backend
# you can't use interpolations (vars for profile, regions etc.) in the backend as it is loaded early (before the variables.tf file)
# Remote state allows you to store the state file for a stack in s3 so it can be shared across ops teams/developers


terraform =  {
  backend "s3" {
  encrypt = "true"
  bucket = "eureka-eks-terraform-state"
  key = "terraform.tfstate" # state file to be created in the s3 bucket
  dynamodb_table = "terraform-state-lock-dynamo"
  profile = "eureka-terraform"
  region = "us-east-2"
  }
}