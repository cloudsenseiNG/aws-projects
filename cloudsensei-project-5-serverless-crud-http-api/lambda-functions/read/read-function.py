# Import necessary modules
import json
import boto3

# Assign a variable ot the boto3 api client to query dynamo DB
dynamo = boto3.client('dynamodb')


def lambda_handler(event, context):
    body = None
    statusCode = 200
    headers = {
    'Content-Type': 'application/json'
    }
    try:
        route_key = event['routeKey']

        if route_key == 'GET /items':
            tables = dynamo.list_tables()
            value = tables['TableNames']
            response = dynamo.scan(
                TableName=value[0]
            )
            body = response['Items']

        elif route_key == 'GET /items/{id}':
            path_params = event['pathParameters']
            tables = dynamo.list_tables()
            value = tables['TableNames']
            response = dynamo.get_item(
                TableName=value[0],
                Key={
                    'id': {'S': path_params['id']}
                }
            )
            body = response['Item']
            
          
        else:
            raise ValueError(f"Unsupported route: '{route_key}'")
    except Exception as err:
        statusCode = 400
        body = str(err)
    finally:
        body = json.dumps(body)

    return {
        'statusCode': statusCode,
        'body': body,
        'headers': headers
    }