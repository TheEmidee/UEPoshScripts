Import-Module -Name ( Resolve-Path( Join-Path -Path ( $PSScriptRoot ) -ChildPath "..\UEPoshScripts.psm1" ) ) -ErrorAction Stop -Force

RunBuild @(
    "$($global:context.ProjectInfos.ProjectName)Editor"
    "Win64"
    "Development"
    "-project=`"$($global:context.ProjectInfos.UProjectPath)`""
    "-WaitMutex"
    "-FromMsBuild"
    "-log=`"$($global:context.ProjectInfos.RootFolder)/Saved/Logs/Compile_Editor_Development_Win64.log"
)