# Verification
After apply:
```bash
curl -i "$(terraform output -raw api_endpoint)"
```
Expected: HTTP 200 and JSON response. Inspect the Lambda log group in CloudWatch. The API is public and unauthenticated by design; add JWT/IAM authorization, throttling, WAF where appropriate, and input validation before production use.
