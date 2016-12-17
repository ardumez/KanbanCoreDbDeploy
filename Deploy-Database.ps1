$databaseName = $args[0]
$databaseServer = $args[1]
$scriptPath = $args[2]

Add-Type -Path (Join-Path -Path (Get-Item -Path ".\" -Verbose).FullName -ChildPath 'DbUp.dll')

$dbUp = [DbUp.DeployChanges]::To
$dbUp = [SqlServerExtensions]::SqlDatabase($dbUp, "server=.;database=KbcList;Trusted_Connection=Yes;Connection Timeout=120;")
$dbUp = [StandardExtensions]::WithScriptsFromFileSystem($dbUp, "C:\Work\KanbanCore\scripts\files")
$dbUp = [SqlServerExtensions]::JournalToSqlTable($dbUp, 'dbo', 'SchemaVersion')
$dbUp = [StandardExtensions]::LogToConsole($dbUp)
$upgradeResult = $dbUp.Build().PerformUpgrade()