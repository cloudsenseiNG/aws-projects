$BUCKETNAME = "crud-serverless-api-bucket-tut"

if ($args.Count -ne 4) {
    Write-Host "No Arguments Passed. Arguments must be exactly 4. Try: create, read, update, delete"
    exit 1
} else {
    Write-Host "Compressing Functions...."
    Start-Sleep -Seconds 2

    $pwdPath = $PWD.Path

    $functions = $args

    foreach ($func in $functions) {
        Compress-Archive -Path "$pwdPath/lambda-functions/$func/$func-function.py" -DestinationPath "$pwdPath/lambda-functions/$func/$func.zip"
    }

    Read-Host -Prompt "Enter Your Region: " -OutVariable REGION

    Write-Host "Creating S3 Bucket..."
    Start-Sleep -Seconds 2

    New-S3Bucket -BucketName $BUCKETNAME -Region $REGION

    Write-Host "Copying Function Artifacts to S3 Bucket..."
    Start-Sleep -Seconds 2

    foreach ($func in $functions) {
        Write-S3Object -BucketName $BUCKETNAME -Key "v1.0.0/$func.zip" -File "$pwdPath/lambda-functions/$func/$func.zip"
    }

    Write-Host "Creating Infrastructure..."
    Start-Sleep -Seconds 2

    terraform init
    terraform apply -auto-approve

    Write-Host "DONE"
    exit 0
}
