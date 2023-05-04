Import-Module -Name ( Resolve-Path( Join-Path -Path ( $PSScriptRoot ) -ChildPath "..\UEPoshScripts.psm1" ) ) -ErrorAction Stop -Force

RunUBT @( 
    "-projectfiles", 
    "-project=$($global:context.ProjectInfos.UProjectPath)",
    "-game",
    "-rocket",
    "-progress" 
)