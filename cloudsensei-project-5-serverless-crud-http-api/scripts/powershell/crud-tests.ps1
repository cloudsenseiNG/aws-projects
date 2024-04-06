$CRUD_ARGS = $args[0]
$API_ARGS = $args[1]

if (-not $CRUD_ARGS -or -not $API_ARGS) {
    Write-Host "Invalid or No Arguments Passed. Try: create, read, readone, update, or delete as ARGS(1) and api-endpoint as ARGS(2)"
    exit 1
} else {
    switch ($CRUD_ARGS) {
        "create" {
            $ID = Read-Host "Enter the ID"
            $NAME = Read-Host "Enter the Name"
            $PRICE = Read-Host "Enter the Price"

            Write-Host "Inserting Values to DynamoDB Table..."
            Start-Sleep -Seconds 2

            $jsonBody = @{
                id = $ID
                name = $NAME
                price = $PRICE
            } | ConvertTo-Json

            Invoke-RestMethod -Method Post -Uri "$API_ARGS/items" -ContentType "application/json" -Body $jsonBody | ConvertTo-Json
        }
        "read" {
            Write-Host "Reading Items From DynamoDB Table..."
            Start-Sleep -Seconds 2

            Invoke-RestMethod -Method Get -Uri "$API_ARGS/items" | ConvertTo-Json
        }
        "readone" {
            $id = Read-Host "Enter an Existing ID"

            Write-Host "Reading Item From DynamoDB Table..."
            Start-Sleep -Seconds 2

            Invoke-RestMethod -Method Get -Uri "$API_ARGS/items/$id" | ConvertTo-Json
        }
        "update" {
            $id = Read-Host "Enter an Existing ID"
            $NAME = Read-Host "Enter the Name"
            $PRICE = Read-Host "Enter the Price"

            Write-Host "Updating Items to DynamoDB Table..."
            Start-Sleep -Seconds 2

            $jsonBody = @{
                name = $NAME
                price = $PRICE
            } | ConvertTo-Json

            Invoke-RestMethod -Method Put -Uri "$API_ARGS/items/$id" -ContentType "application/json" -Body $jsonBody | ConvertTo-Json
        }
        "delete" {
            $id = Read-Host "Enter an Existing ID"

            Write-Host "Deleting Item from DynamoDB Table..."
            Start-Sleep -Seconds 2

            Invoke-RestMethod -Method Delete -Uri "$API_ARGS/items/$id" | ConvertTo-Json
        }
        default {
            Write-Host "Invalid First Argument. Try: either 'create', 'read', 'readone', 'update', 'delete'"
            exit 1
        }
    }
}
