terraform {
    backend "s3" {
        bucket = "cicd-bucket"
        key    = "eks/terraform.tfstate"
        region = "eu-west-3"
    }
}
