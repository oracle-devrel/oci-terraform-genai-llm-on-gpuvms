## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

### Common Variables
variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
}
variable "compartment_ocid" {
  description = "OCI Compartment OCID"
}
 variable "user_ocid" {
   description = "User OCID"
 }
 variable "fingerprint" {
   description = "User fingerprint"
 }
 variable "private_key_path" {
   description = "User key path"
 }
variable "region" {
  description = "OCI Region"
}
variable "app_name" {
  default     = "gpuA10"
  description = "A short prefix for resource"
}
variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "0.0"
}
### VCN Related Variables
variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "Subnet-CIDR" {
  default = "10.0.1.0/24"
}
### Variables for Compute
variable "instance_shape" {
  description = "Instance Shape"
  default     = "BM.GPU.A10.4"
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "8"
}
variable "gpu_os_version"{
  description = "Validated os image"
  default = "Oracle-Linux-8.9-Gen2-GPU-2024.04.19-0"
}
variable "ssh_public_key" {
  type = string
  description = "The public SSH key to use for the compute instance"
  default     = ""
}
variable "ssh_public_key_path" {
  type = string
  description = "The path to the public SSH key to use for the compute instance"
  default     = ""
}
variable "availability_domain_name" {
  default = ""
}
variable "boot_volume_size_in_gbs" {
  default = 1700
  description = "boot bolume size"
}
variable "boot_volume_vpus_per_gb" {
  default = 10
  description = "boot volume performance factor (multiple of 10) "
}
#Gateway related variables.
variable "create_api_gateway" {
  default = true
  description = "Set false to use an existing gateway"
}
variable "endpoint_type" {
  default = "PUBLIC"
}
variable "path_prefix" {
  default = "/a10"
}
variable "connect_timeout_in_seconds" {
  default = 60
}
variable "send_timeout_in_seconds" {
  default = 10
}
variable "openai_port" {
  default = 9001
}
variable "default_port" {
  default = 9000
}
variable "route_prefix" {
  default = "/llm"
}
#LLM specific variable
variable "model_path" {
  description = "LLM Path"
}
variable "huggingface_access_token" {
  description = "HF read token"
}