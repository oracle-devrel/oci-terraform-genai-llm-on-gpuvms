# Communicate with Oracle's API Gateway endpoint to make 
# requests to the LLM.
import requests

url = "YOUR TERRAFORM-GENERATED API GATEWAY URL"
token = "YOUR TERRAFORM-GENERATED TOKEN"

# list models available
response = requests.get(url,
    headers={'Authorization': 'Bearer {}'.format(token)})

print(response.text)