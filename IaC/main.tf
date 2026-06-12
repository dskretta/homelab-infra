// This is the example main.tf file for provisioning a VM

terraform {
    required_providers {
        proxmox = {
            source  = "bpg/proxmox"
            version = "0.97.0"
        }
        vault   = {
            source  = "hashicorp/vault"
            version = "5.7.0"
        }
    }
}


provider "vault" {
    skip_child_token = true
    skip_tls_verify  = true
    auth_login {
        path = "auth/approle/login"
        parameters = {
            role_id   = var.role_id
            secret_id = var.secret_id
        }
    }
}

ephemeral "vault_kv_secret_v2" "pve_creds" {
    mount = "proxmox"
    name  = "terraform"
}

provider "proxmox" {
    endpoint  = var.proxmox_endpoint
    insecure  = true
    api_token = "${ephemeral.vault_kv_secret_v2.pve_creds.data["token_id"]}=${ephemeral.vault_kv_secret_v2.pve_creds.data["token_secret"]}"    
}

resource "proxmox_virtual_environment_vm" "test_vm" {
    name      = "terraform-test"
    node_name = "home"
    vm_id     = 900
    started   = false
}
