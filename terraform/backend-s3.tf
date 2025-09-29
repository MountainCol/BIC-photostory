terraform {
    backend "s3" {
        bucket = "bic-photostory"
        key    = "terraform.tfstate"
        region = "eu-west-2"
    }
}
