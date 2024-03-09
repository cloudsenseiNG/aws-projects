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
        path_params = event['pathParameters']

        if route_key == 'PUT /items/{id}':
            request_json = json.loads(event['body'])
            tables = dynamo.list_tables()
            value = tables['TableNames']
            dynamo.put_item(
                TableName=value[0],
                Item={
                    'id': {'S': path_params['id']},
                    'price': {'S': request_json['price']},
                    'name': {'S': request_json['name']}
                }
            )
            body = f"Put item {path_params['id']}"
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