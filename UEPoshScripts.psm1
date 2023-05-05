class EngineDefinition
{
    [String] $EngineAssociation
    [Version] $Version
}

class InstalledEngineDefinition
{
    [EngineDefinition] $EngineDefinition
    [String] $Path
}

class ProjectInfos
{
    [String] $Folder;
    [String] $Name;
    [String] $FullPath;
}

$ScriptFiles = Get-ChildItem -Recurse "$PSScriptRoot\Utils" -Include *.ps1 
 
foreach ( $ScriptFile in $ScriptFiles ) { 
    . $ScriptFile.FullName
}
 
$global:context = New-Object Context

Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."
Write-Host

$ConfigFolder = Join-Path $global:context.Projectinfos.Folder -ChildPath "Config\PoshScripts"

$ConfigFiles = Get-ChildItem -Recurse $ConfigFolder -Include *.ps1

foreach ( $ConfigFile in $ConfigFiles ) { 
    . $ConfigFile.FullName 
    
    Write-Host "Loaded config file $($ConfigFile.FullName )" -ForegroundColor Green
}

Write-Host