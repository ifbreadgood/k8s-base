terraform {
  required_version = "~> 1.12.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0.0"
    }
  }
}

provider "vault" {
  address = "https://vault.trial.studio"
}

variable "name" {
  type = string
}

data "vault_auth_backend" "this" {
  path = "kubernetes"
}

resource "vault_aws_secret_backend_role" "this" {
  backend         = "aws"
  name            = "route53-dns-challenge"
  credential_type = "iam_user"
  policy_document = <<EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "route53:ListHostedZones",
            "route53:GetChange"
          ],
          "Resource": ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : ["route53:ChangeResourceRecordSets"],
          "Resource" : ["arn:aws:route53:::hostedzone/Z06285332QCWSWF1RDQBK"]
        }
      ]
    }
    EOT
}

resource "vault_policy" "this" {
  name = var.name

  policy = <<-EOT
    path "${vault_aws_secret_backend_role.this.backend}/creds/${vault_aws_secret_backend_role.this.name}" {
      capabilities = ["read"]
    }
    path "pki_int/*" {
      capabilities = ["read"]
    }
    EOT
}

resource "vault_kubernetes_auth_backend_role" "this" {
  # backend = data.vault_auth_backend.this
  bound_service_account_names      = ["vault-${var.name}"]
  bound_service_account_namespaces = [var.name]
  role_name                        = var.name
  token_policies                   = [vault_policy.this.name]
  audience                         = "external-secrets-operator"
  token_ttl                        = 60 * 60 * 24
}