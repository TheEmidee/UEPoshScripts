function CI_CleanupSharedStorage {

    param(
        [Parameter(Mandatory = $true)][String] $BuildTag
    )

    $SharedStorageDir = "$($global:JenkinsConfig.BUILDGRAPH_SHARED_STORAGE_PATH)\$($BuildTag)"

    Write-Host "Delete Buildgraph Shared Storage folder : $($SharedStorageDir)"
    Remove-Item $SharedStorageDir -Recurse -ErrorAction Ignore
}