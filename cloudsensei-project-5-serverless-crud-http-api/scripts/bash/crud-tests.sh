#!/bin/bash

CRUD_ARGS=${1}
API_ARGS=${2}

if [[ -z $CRUD_ARGS || -z $API_ARGS ]]; then

    echo "Invalid or No Arguments Passed. Try: create, read, readone, update or delete as ARGS(1) and api-endpoint as ARGS(2)"
    
    exit 1

else

    case ${CRUD_ARGS} in 

        "create")
        read -p "Enter the ID: " ID

        read -p "Enter the Name: " NAME

        read -p "Enter the Price: " PRICE

        echo "Inserting Values to DynamoDB Table..."

        sleep 2

        curl -X "POST" -H "Content-Type: application/json" \
        -d "{\"id\": \"${ID}\", \"name\": \"${NAME}\", \"price\": \"${PRICE}\" }" \
        ${API_ARGS}/items | json_pp
        ;;

        "read")
        echo "Reading Items From DynamoDB Table..."

        sleep 2

        curl -s ${API_ARGS}/items | json_pp
        ;;

        "readone")
        read -p "Enter an Existing ID: " id

        echo "Reading Item From DynamoDB Table..."
        
        sleep 2

        curl -s ${API_ARGS}/items/${id} | json_pp
        ;;

        "update")
        read -p "Enter an Existing ID: " id

        read -p "Enter the Name: " NAME

        read -p "Enter the Price: " PRICE

        echo "Updating Items to DynamoDB Table..."

        sleep 2

        curl -X "PUT" -H "Content-Type: application/json" \
        -d "{\"name\": \"${NAME}\", \"price\": \"${PRICE}\" }" \
        ${API_ARGS}/items/${id} | json_pp
        ;;

        "delete")
        
        read -p "Enter an Existing ID: " id

        echo "Deleting Item from DynamoDB Table..."

        sleep 2

        curl -X "DELETE" ${API_ARGS}/items/${id} | json_pp
        ;;

        *)

        echo "Invalid First Argument. Try: either "create", "read", "readone", "update", "delete""

        exit 1  
        ;;

    esac   

fi   
