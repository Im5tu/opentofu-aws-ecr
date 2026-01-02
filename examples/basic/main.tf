module "example" {
  source = "../.."

  repo_name             = "example-repo"
  push_principal_access = []

  tags = {
    Environment = "example"
  }
}
