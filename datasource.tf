## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}
#Instance refernce
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version

  filter{
    name = "display_name"
    values = [var.gpu_os_version]
    regex  = true

  }

  #shape      = var.instance_shape
  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}


# Gets home and current regions
data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid
  provider   = oci.current_region
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }

  provider = oci.current_region
}

data "oci_identity_regions" "current_region" {
  filter {
    name   = "name"
    values = [var.region]
  }
  provider = oci.current_region
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

resource "random_id" "api_key" {
  byte_length = 64
}

## Object Storage
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}
#For cloud config
data "template_file" "bootstrap" {
  template = file("${path.module}/cloud-init/bootstrap")
}


data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap.rendered
  }
}