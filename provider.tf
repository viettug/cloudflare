terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  email     = "YOUR_EMAIL@GMAIL.COM"
  api_token = trimspace(file("credentials.txt"))
}
