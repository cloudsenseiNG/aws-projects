#!/bin/bash

BUCKETNAME="crud-serverless-api-bucket-tut"

if [[ -z $1 || -z $2 || -z $3 || -z $4 ]]; then

    echo "No Arguments Passed. Arguments must be exactly 4. Try: create, read, update, delete"

    exit 1

else
  
    echo "Compressing Functions...."

    sleep 2

    cd $(pwd)/lambda-functions/${1}/
    zip ${1}.zip ${1}-function.py

    cd -

    cd $(pwd)/lambda-functions/${2}/
    zip ${2}.zip ${2}-function.py

    cd -

    cd $(pwd)/lambda-functions/${3}/
    zip ${3}.zip ${3}-function.py

    cd -

    cd $(pwd)/lambda-functions/${4}/
    zip ${4}.zip ${4}-function.py

    cd -

    read -p "Enter Your Region: " REGION

    echo "Creating S3 Bucket..."

    sleep 2

    aws s3api create-bucket --bucket $BUCKETNAME --region $REGION

    echo "Copying Function Artifacts to S3 Bucket..."

    sleep 2

    aws s3 cp $(pwd)/lambda-functions/${1}/${1}.zip  s3://$BUCKETNAME/v1.0.0/${1}.zip

    aws s3 cp $(pwd)/lambda-functions/${2}/${2}.zip  s3://$BUCKETNAME/v1.0.0/${2}.zip

    aws s3 cp $(pwd)/lambda-functions/${3}/${3}.zip  s3://$BUCKETNAME/v1.0.0/${3}.zip

    aws s3 cp $(pwd)/lambda-functions/${4}/${4}.zip  s3://$BUCKETNAME/v1.0.0/${4}.zip

    echo "Creating Infrastructure..."

    sleep 2

    terraform init
    terraform apply -auto-approve

    echo "DONE"
    
    exit 0

fi
