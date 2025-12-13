import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume') 

def lambda_handler(event, context):
    response = table.update_item(
        Key={
            'id': '1'
        },
        UpdateExpression='SET #v = #v + :inc',
        
        ExpressionAttributeNames={
            '#v': 'views'
        },
        
        ExpressionAttributeValues={
            ':inc': 1
        },
        ReturnValues="UPDATED_NEW"
    )
    visit_count = int(response['Attributes']['views'])
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps({'count': visit_count})
    }