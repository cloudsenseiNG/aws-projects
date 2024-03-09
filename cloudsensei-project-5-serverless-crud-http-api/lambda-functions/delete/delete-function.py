import json
import boto3

dynamo = boto3.client('dynamodb')


def lambda_handler(event, context):
    
    body = None
    statusCode = 200
    headers = {
    'Content-Type': 'application/json'
    }
    
    try:
        route_key = event['routeKey']
        path_params = event['pathParameters']
        
        if route_key == 'DELETE /items/{id}':
            tables = dynamo.list_tables()
            value = tables['TableNames']
            dynamo.delete_item(
                TableName=value[0],
                Key={
                    'id': {'S': path_params['id']}
                }
            )
            body = f"Deleted item {path_params['id']}"
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