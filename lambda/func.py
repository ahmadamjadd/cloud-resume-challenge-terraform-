import json
import boto3

# 1. Connect to the higher-level "Resource" (Easier than Client)
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume')  # Replace with your actual table name

def lambda_handler(event, context):
    # 2. The Atomic Update
   # 2. The Atomic Update
    response = table.update_item(
        Key={
            'id': '1'
        },
        # USE THE ALIAS (#v) HERE:
        UpdateExpression='SET #v = #v + :inc',
        
        # DEFINE THE ALIAS HERE:
        ExpressionAttributeNames={
            '#v': 'views'
        },
        
        ExpressionAttributeValues={
            ':inc': 1
        },
        ReturnValues="UPDATED_NEW"
    )
    # 3. Get the new count from the response
    # It usually comes back as a Decimal, so we convert it to int/float for JSON
    visit_count = int(response['Attributes']['views'])
    
    return {
        'statusCode': 200,
        # Enable CORS so your website can talk to this Lambda
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps({'count': visit_count})
    }