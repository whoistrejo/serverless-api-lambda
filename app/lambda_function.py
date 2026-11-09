import json

def handler(event, context):
    body = {
        "message": "Hello from the AWS serverless portfolio lab",
        "path": event.get("rawPath", "/"),
        "method": event.get("requestContext", {}).get("http", {}).get("method", "UNKNOWN"),
    }
    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }
