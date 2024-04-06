$BUCKETNAME = "crud-serverless-api-bucket-tut"

Write-Host "Deleting S3 Bucket..."
Start-Sleep -Seconds 2

Remove-S3Bucket -BucketName $BUCKETNAME -Force

Write-Host "Deleting Infrastructure..."
Start-Sleep -Seconds 2

terraform destroy -auto-approve
