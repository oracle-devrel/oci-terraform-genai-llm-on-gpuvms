# Copyright (c) 2024 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_apigateway_gateway" "apigw" {
  count = var.create_api_gateway ? 1:0
  compartment_id = var.compartment_ocid
  endpoint_type  = var.endpoint_type
  subnet_id      = oci_core_subnet.subnet.id

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  display_name               = "${var.app_name}_gateway"
  response_cache_details {
    type = "NONE"
  }
  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
# APIGateway Deployment
resource "oci_apigateway_deployment" "apigw_deployment" {
  compartment_id = var.compartment_ocid
  gateway_id     = oci_apigateway_gateway.apigw[0].id
  path_prefix    = var.path_prefix
  specification {
    request_policies {
      mutual_tls {
        allowed_sans                     = []
        is_verified_certificate_required = false
      }
    }
    routes {
      backend {
        type                       = "HTTP_BACKEND"
        connect_timeout_in_seconds = var.connect_timeout_in_seconds
        is_ssl_verify_disabled     = true
        send_timeout_in_seconds    = var.send_timeout_in_seconds
        url                        = "http://${oci_core_instance.llm_host.public_ip}:${var.openai_port}/$${request.path[endpoints]}"
      }
      path = "${var.route_prefix}/{endpoints*}"

      methods = ["ANY"]
      request_policies {
        header_transformations {

          set_headers {
            items {
              name   = "access_token"
              values = ["rahulmr"]
              if_exists = "OVERWRITE"
            }
          }
        }
      }
    }
  }

  display_name = "${var.app_name}_apigateway_deployment_${random_string.deploy_id.id}"
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}