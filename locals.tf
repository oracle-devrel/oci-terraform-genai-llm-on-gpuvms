# Copyright (c) 2021 Oracle and/or its affiliates.

locals {
  #private_key = try(file(var.private_key_path), var.private_key)
  ssh_public_key = try(file(var.ssh_public_key_path), var.ssh_public_key)

  ssh_public_keys = join("\n", [
    trimspace(local.ssh_public_key),
    trimspace(tls_private_key.tls_private_key.public_key_openssh)
  ])

}