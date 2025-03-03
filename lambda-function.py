import json
import os
import requests

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

    # Jenkins API URL to trigger the job
    jenkins_trigger_url = f"{JENKINS_URL}/job/{JOB_NAME}/build"

    # Trigger Jenkins pipeline
    response = requests.post(jenkins_trigger_url, auth=(JENKINS_USER, JENKINS_API_TOKEN))

    if response.status_code == 201:
        print(f"✅ Jenkins job '{JOB_NAME}' triggered successfully!")
    else:
        print(f"❌ Failed to trigger Jenkins job. Response: {response.status_code} - {response.text}")

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda successfully triggered Jenkins!')
    }
