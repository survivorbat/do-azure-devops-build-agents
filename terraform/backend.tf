terraform {
  backend "s3" {
    bucket = "__terraformBackendBucket__"
    key = "__terraformBackendKey__"
    access_key = "__doAccessKey__"
    secret_key = "__doSecretKey__"
    endpoint = "https://ams3.digitaloceanspaces.com"
    region = "eu-west-1"
    skip_credentials_validation = true
    skip_metadata_api_check = true
  }
}
