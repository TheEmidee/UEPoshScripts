function GetBuildGraphJSON( [string] $BuildGraphTarget, [ hashtable ] $Properties = @{} ) {
    $TempFolder = $global:context.ProjectInfos.ProjectFolders.SavedFolders.Temp

    if ( -not ( Test-Path $TempFolder ) ) {
        New-Item -Path $TempFolder -ItemType "Directory"
    }
    
    $OutputPath = Join-Path -Path $TempFolder -ChildPath "BuildGraph.json"
    RunBuildGraph $BuildGraphTarget $Properties " -Export=`"$($OutputPath)`" uebp_UATMutexNoWait=1"

    return Get-Content -Raw -Path $OutputPath | ConvertFrom-Json
}