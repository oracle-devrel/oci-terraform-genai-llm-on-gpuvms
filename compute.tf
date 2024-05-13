# Copyright (c) 2024 Oracle and/or its affiliates.

resource oci_core_instance llm_host {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  shape = var.instance_shape
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
  }

  create_vnic_details {
    assign_public_ip = "true"
    display_name  = "llm_host_publicip"
    skip_source_dest_check = "false"
    subnet_id              = oci_core_subnet.subnet.id
  }

  display_name      = "${var.app_name}_llmhost"

  metadata = {
    ssh_authorized_keys = local.ssh_public_keys
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  source_details {
    source_id = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
    source_type = "image"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    boot_volume_vpus_per_gb = var.boot_volume_vpus_per_gb
  }
  lifecycle {
    ignore_changes = [defined_tags]
  }
  #-ENV Setup
  connection {
    agent       = false
    timeout     = "60m"
    host        = oci_core_instance.llm_host.public_ip
    user        = "opc"
    private_key = tls_private_key.tls_private_key.private_key_pem
  }

  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/home/opc/setup.sh"

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }
  #-Copy default service
  provisioner "file" {
    source      = "scripts/default.svc"
    destination = "/home/opc/default.svc"

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }

  #Copy openai service
  provisioner "file" {
    source      = "scripts/openai.svc"
    destination = "/home/opc/openai.svc"

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }
  #Running Exec
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/setup.sh",
      "export api_key=${random_id.api_key.id}",
      "export model_path=${var.model_path}",
      "export huggingface_access_token=${var.huggingface_access_token}",
      "export llm_port_default=${var.default_port}",
      "export llm_port_openai=${var.openai_port}",
      "bash /home/opc/setup.sh"
    ]

    connection {
      private_key = tls_private_key.tls_private_key.private_key_pem
      user = "opc"
      host = self.public_ip
    }
  }
}

