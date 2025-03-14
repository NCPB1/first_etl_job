
import sys
import os

# Dynamically add the 'package' directory to sys.path
sys.path.append(os.path.join(os.path.dirname(__file__), 'package'))

import json
import requests
from requests.auth import HTTPBasicAuth

# Load environment variables from Lambda configuration
JENKINS_URL = os.environ['JENKINS_URL']
JENKINS_USER = os.environ['JENKINS_USER']
JENKINS_API_TOKEN = os.environ['JENKINS_API_TOKEN']
JOB_NAME = os.environ['JOB_NAME']

def lambda_handler(event, context):
    print("Received event: ", json.dumps(event))

    # Extract object details from the S3 event
    record = event['Records'][0]
    bucket_name = record['s3']['bucket']['name']
    object_key = record['s3']['object']['key']

    print(f"New file uploaded: s3://{bucket_name}/{object_key}")

    # Get the CSRF crumb from Jenkins
    csrf_url = f"{JENKINS_URL}/crumbIssuer/api/json"
    csrf_response = requests.get(csrf_url, auth=HTTPBasicAuth(JENKINS_USER, JENKINS_API_TOKEN))

    if csrf_response.status_code != 200:
        print(f"❌ Failed to fetch CSRF crumb. Response: {csrf_response.status_code} - {csrf_response.text}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error fetching CSRF crumb.')
        }

    csrf_token = csrf_response.json().get('crumb')
    print(f"✅ CSRF crumb fetched successfully: {csrf_token}")

    # Jenkins API URL to trigger the job
    jenkins_trigger_url = f"{JENKINS_URL}/job/{JOB_NAME}/build"

    headers = {'Jenkins-Crumb': csrf_token}

    # Trigger Jenkins pipeline
    response = requests.post(jenkins_trigger_url, auth=HTTPBasicAuth(JENKINS_USER, JENKINS_API_TOKEN), headers=headers)

    if response.status_code == 201:
        print(f"✅ Jenkins job '{JOB_NAME}' triggered successfully!")
    else:
        print(f"❌ Failed to trigger Jenkins job. Response: {response.status_code} - {response.text}")

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda successfully triggered Jenkins!')
    }

  
