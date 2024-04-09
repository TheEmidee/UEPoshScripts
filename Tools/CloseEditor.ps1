Import-Module -Name ( Resolve-Path( Join-Path -Path ( $PSScriptRoot ) -ChildPath "..\UEPoshScripts.psm1" ) ) -ErrorAction Stop -Force

$processName = "UnrealEditor*"

$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ( $process ) {
    $choice = Read-Host "The editor is already running. Do you want to stop it? (Y/N)"
    
    # Check the user's response
    if ( $choice -eq "Y" -or $choice -eq "y" ) {
        Stop-Processes -processName $processName
    }
}