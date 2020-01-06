param([Int32]$batchNumber, [Int32]$batchSize=4)

$filters = @(
    "PartitionKey lt ''", 
	"PartitionKey ge '' and PartitionKey le ''", 
	"PartitionKey ge '' and PartitionKey le ''", 
	"PartitionKey gt ''"
)

$azureTableConnectionString = ""
$cosmosDbAccountConnectionString = ""

$startIndex = (($batchNumber - 1) * $batchSize);
$endIndex = [math]::min(($startIndex + $batchSize), $filters.Length);

for ($i=$startIndex; $i -lt $endIndex; $i++) {
	invoke-expression "cmd /c start powershell -NoExit -Command {
        Write-Host ""$($filters[$i])"";
        .\dt.exe /s:AzureTable /s.ConnectionString:""$($azureTableConnectionString)"" /s.Table:DataTable /s.Filter:""$($filters[$i])"" /t:TableAPIBulk /t.MaxBatchSize:572864 /t.ConnectionString:""$($cosmosDbAccountConnectionString)"" /t.TableName:ProjectData /ErrorLog:logs/""$($filters[$i])"".txt /OverwriteErrorLog;
	}"
}

if ($batchNumber -eq 1) {
    Write-Host "Scheduled tasks";
    .\dt.exe /s:AzureTable /s.ConnectionString:""$($azureTableConnectionString)"" /s.Table:ScheduledTasks /t:TableAPIBulk /t.ConnectionString:""$($cosmosDbAccountConnectionString)"" /t.TableName:ScheduledTasks /ErrorLog:logs/scheduledTasks.txt /OverwriteErrorLog;

    Write-Host "Long running tasks";
    .\dt.exe /s:AzureTable /s.ConnectionString:""$($azureTableConnectionString)"" /s.Table:LongRunningTasks /t:TableAPIBulk /t.ConnectionString:""$($cosmosDbAccountConnectionString)"" /t.TableName:LongRunningTasks /ErrorLog:logs/longRunningTasks.txt /OverwriteErrorLog;
}


