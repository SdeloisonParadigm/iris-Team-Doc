<#
.SYNOPSIS
    Securely read and write CSV files stored in Azure Blob Storage using a Managed Identity.

.DESCRIPTION
    - Connects to Azure via Managed Identity
    - Downloads a CSV file from a container
    - Processes the CSV (example section to customize)
    - Uploads the processed CSV back to Blob Storage

.NOTES
    Author: Stephane version – Managed Identity CSV Handler
    Requires: Az.Accounts, Az.Storage
    Role: Storage Blob Data Contributor (on the target storage account)
#>

# =============================
# 🔧 CONFIGURATION VARIABLES
# =============================
$storageAccountName = "mystorageaccount"     #  Replace with your storage account name
$containerNameIn    = "guest-data"           #  Input container name
$blobNameIn         = "GuestsImport.csv"     #  Input CSV blob name

$containerNameOut   = "guest-processed"      #  Output container name (can be same as input)
$blobNameOut        = "GuestsProcessed.csv"  #  Output CSV blob name

# =============================
#  AUTHENTICATION
# =============================
Write-Host " Connecting to Azure using Managed Identity..."
Connect-AzAccount -Identity

Write-Host "  Creating storage context for account: $storageAccountName"
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount

# =============================
#  DOWNLOAD CSV FROM BLOB
# =============================
Write-Host "  Downloading CSV from container '$containerNameIn'..."
$tempInput = Join-Path $env:TEMP $blobNameIn

Get-AzStorageBlobContent `
    -Container $containerNameIn `
    -Blob $blobNameIn `
    -Destination $tempInput `
    -Context $ctx `
    -Force | Out-Null

Write-Host " CSV downloaded to: $tempInput"

# =============================
#  LOAD CSV DATA
# =============================
Write-Host " Importing CSV data..."
$csvData = Import-Csv -Path $tempInput

Write-Host "--- CSV CONTENT PREVIEW (first 5 rows) ---"
$csvData | Select-Object -First 5 | Format-Table

# =============================
#  PROCESSING SECTION
# =============================
Write-Host "  Processing CSV data..."
$processedData = @()

foreach ($row in $csvData) {
    # Example transformation — customize to your need
    $processedData += [PSCustomObject]@{
        DisplayName = $row.DisplayName
        Email       = $row.Email
        Status      = "Processed"
        ProcessDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
}

Write-Host " Processing complete. Total rows processed: $($processedData.Count)"

# =============================
#  SAVE PROCESSED DATA LOCALLY
# =============================
$tempOutput = Join-Path $env:TEMP $blobNameOut
$processedData | Export-Csv -Path $tempOutput -NoTypeInformation -Encoding UTF8

Write-Host " Processed CSV saved locally to: $tempOutput"

# =============================
#  UPLOAD BACK TO BLOB STORAGE
# =============================
Write-Host "  Uploading processed CSV to container '$containerNameOut'..."
Set-AzStorageBlobContent `
    -File $tempOutput `
    -Container $containerNameOut `
    -Blob $blobNameOut `
    -Context $ctx `
    -Force | Out-Null

Write-Host " File successfully uploaded to: https://$storageAccountName.blob.core.windows.net/$containerNameOut/$blobNameOut"

# =============================
#  CLEANUP (optional)
# =============================
Remove-Item $tempInput, $tempOutput -ErrorAction SilentlyContinue
Write-Host "`n🧹 Temporary files cleaned up."
Write-Host "`n🚀 Script completed successfully!"
