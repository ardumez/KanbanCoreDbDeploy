$databaseName = $args[0]
$databaseServer = $args[1]
$scriptPath = $args[2]

Add-Type -Path (Join-Path -Path (Get-Item -Path ".\" -Verbose).FullName -ChildPath 'DbUp.dll')

$dbUp = [DbUp.DeployChanges]::To
$dbUp = [SqlServerExtensions]::SqlDatabase($dbUp, "server=$env:serverName;database=KbcList;Trusted_Connection=Yes;Connection Timeout=120;")
$dbUp = [StandardExtensions]::WithScriptsFromFileSystem($dbUp, "C:\Work\KanbanCore\scripts\files")
$dbUp = [SqlServerExtensions]::JournalToSqlTable($dbUp, 'dbo', 'SchemaVersion')
$dbUp = [StandardExtensions]::LogToConsole($dbUp)
$result = $dbUp.Build().PerformUpgrade()
if (!$result.Successful) {
    $errorMessage = ""
    if ($result.Error -ne $null) {
        $errorMessage = $result.Error.Message
    }
    Write-Host "##vso[task.logissue type=error;]Database migration failed. $errorMessage"
    Write-Host "##vso[task.complete result=Failed;]"
    Exit -1
}