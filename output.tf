output "OS_IMAGE" {
  value = data.oci_core_images.InstanceImageOCID.images[*].display_name
}
output "HOST_PUBLIC_IP" {
  value = oci_core_instance.llm_host.public_ip
}
output "API_KEY" {
  value = random_id.api_key.id
}
output "LLM_URL" {
  value = "${oci_apigateway_deployment.apigw_deployment.endpoint}${var.route_prefix}"
}
output "General_Message" {
  value = " It will take 5 or more minutes to get your first response as the LLM need to get installed with in the host\n You can view the logs by logging in the hosts \n Refer Repo readme for more..."
}