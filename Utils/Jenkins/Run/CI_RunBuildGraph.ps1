function CI_RunBuildGraph {
    param(
    [Parameter(Mandatory = $true)][string] $BuildGraphTarget,
    [Parameter(Mandatory = $true)][string] $BuildTag,
    [string] $TaskProperties = ""
    )

    $SharedStorageDir = "$($global:JenkinsConfig.BUILDGRAPH_SHARED_STORAGE_PATH)\$($BuildTag)"

    $ExtraArguments += " $($TaskProperties) -BuildMachine -SharedStorageDir=`"$($SharedStorageDir)`" -WriteToSharedStorage -SingleNode=`"$($BuildGraphTarget)`" -NoP4"

    $TaskSharedStorageDir = "$($SharedStorageDir)\$($BuildGraphTarget)"
    Write-Host "Remove task shared storage dir $($TaskSharedStorageDir)"
    Remove-Item $TaskSharedStorageDir -Recurse -ErrorAction Ignore

    $SavedFolder = $global:context.ProjectInfos.ProjectFolders.Saved

    if ( -not( Test-Path $SavedFolder ) ) {
        New-Item $SavedFolder -ItemType Directory
        Write-Host "Created folder $($SavedFolder)"
    }

    $MustDeleteLocalBuildgraphFolder = $False
    $BuildgraphLocalFolder = $global:context.ProjectInfos.ProjectFolders.SavedFolders.Buildgraph
    $CITaskVersionFile = Join-Path -Path $SavedFolder -ChildPath "CITaskVersionFile.txt"

    if ( Test-Path $CITaskVersionFile ) {
        Write-Host "Found CITaskVersionFile.txt"
        $Version = Get-Content -Path $CITaskVersionFile
        if ( $Version -ne $BuildTag ) {
            Write-Host "CITaskVersionFile.txt contains a different build tag ( $($Version) ) than what is being built ( $($BuildTag) )"
            $MustDeleteLocalBuildgraphFolder = $True
        }
    } else {
        Write-Host "Cannot find CITaskVersionFile.txt"
        Set-Content -Path $CITaskVersionFile -Value $BuildTag
    }

    if ( $MustDeleteLocalBuildgraphFolder -eq $True ) {
        Write-Host "Remove Local folder : $($BuildgraphLocalFolder)"
        Remove-Item $BuildgraphLocalFolder -Recurse -ErrorAction Ignore

        Set-Content -Path $CITaskVersionFile -Value $BuildTag
    }

    $JenkinsFolder = $global:context.ProjectInfos.ProjectFolders.SavedFolders.Jenkins
    Write-Host "Remove Jenkins folder : $($JenkinsFolder)"
    Remove-Item $JenkinsFolder -Recurse -ErrorAction Ignore

    $TestsFolder = $global:context.ProjectInfos.ProjectFolders.SavedFolders.Tests
    Write-Host "Remove Tests folder : $($TestsFolder)"
    Remove-Item $TestsFolder -Recurse -ErrorAction Ignore

    Exit RunBuildGraph "" @{} $ExtraArguments
}