provider "aws" {
  profile = "trainee"

  region = var.region

  default_tags {
    tags = {
      Owner = "Uladzimir Boki"
    }
  }
}