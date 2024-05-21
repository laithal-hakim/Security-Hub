terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
  required_version = "~>1.7"
}

provider "aws" {
  region  = "eu-west-1"

  default_tags {
    // https://tombola.atlassian.net/wiki/spaces/IA/pages/4473946193/Tagging+Policy
    tags = {
      name         = "EC2 Security Group Clean-up"
      environment  = "pg"
      tenant       = "Core"
      organisation = "tombolaltd"
      team         = "INFOSEC"
      repo         = "https://github.com/laithal-hakim/Security-Hub"
    }
  }
}
