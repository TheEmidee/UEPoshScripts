Import-Module -Name ( Resolve-Path( Join-Path -Path ( $PSScriptRoot ) -ChildPath "..\UEPoshScripts.psm1" ) ) -ErrorAction Stop -Force

RunEditor @( )