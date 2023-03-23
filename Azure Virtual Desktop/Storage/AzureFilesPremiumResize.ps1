# Parameters
$subscriptionId = ""
$resourceGroupName = ""
$storageAccountName = ""
$fileShareName = ""

# Log in to your Azure account
Connect-AzAccount

# Set the subscription context
Select-AzSubscription -SubscriptionId $subscriptionId

# Get the file share properties
$fileShare = Get-AzRmStorageShare -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -Name $fileShareName -GetShareUsage

# Calculate the used and total space in bytes
$usedSpace = $fileShare.UsedBytes
$totalSpace = $fileShare.QuotaGiB * 1024 * 1024 * 1024

# Calculate the desired free space (20%)
$desiredFreeSpace = $totalSpace * 0.20

# Calculate the new quota size in GiB
$newQuotaSizeGiB = [Math]::Ceiling(($usedSpace + $desiredFreeSpace) / (1024 * 1024 * 1024))

# Set the minimum and maximum file share size in GiB
$minQuotaSizeGiB = 100
$maxQuotaSizeGiB = 102400

# Ensure the new quota size is within the allowed range
$newQuotaSizeGiB = [Math]::Max($minQuotaSizeGiB, [Math]::Min($maxQuotaSizeGiB, $newQuotaSizeGiB))

# Update the file share size
if ($newQuotaSizeGiB -ne $fileShare.QuotaGiB) {
    update-AzRmStorageShare -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -Name $fileShareName -QuotaGiB $newQuotaSizeGiB
    Write-Host "File share size has been adjusted to $newQuotaSizeGiB GiB."
} else {
    Write-Host "File share size is already optimal."
}

