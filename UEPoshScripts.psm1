$ScriptFiles = Get-ChildItem -Recurse "$PSScriptRoot\Utils" -Include *.ps1 
 
foreach ( $ScriptFile in $ScriptFiles ) { 
    . $ScriptFile.FullName
}
 
$global:context = [Context]::new()

Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."
Write-Host

$ConfigFolder = Join-Path $global:context.Projectinfos.RootFolder -ChildPath "Config\PoshScripts"

$ConfigFiles = Get-ChildItem -Recurse $ConfigFolder -Include *.ps1

foreach ( $ConfigFile in $ConfigFiles ) { 
    . $ConfigFile.FullName 
    
    Write-Host "Loaded config file $($ConfigFile.FullName )" -ForegroundColor Green
}

Write-Host