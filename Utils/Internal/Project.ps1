class ProjectInfos
{
    [String] $Folder;
    [String] $ProjectName;
    [String] $UProjectPath;

    [void] DumpToHost(){
        Write-Host "----- Project infos -----"
        Write-Host " * Folder : $($this.Folder)"
        Write-Host " * ProjectName : $($this.ProjectName)"
        Write-Host " * UProjectPath : $($this.UProjectPath)"
        Write-Host "----- Project infos -----"
        Write-Host ""
    }
}

function Get-ProjectInfos() {
    $project_infos = [ProjectInfos]::new()

    $project_infos.Folder = Resolve-Path ( Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\" )
    $u_project_name = Get-ChildItem $project_infos.Folder -File '*.uproject'

    if ( $null -eq $u_project_name ) {
        throw "Impossible to find a uproject file"
    }

    $project_infos.ProjectName = $u_project_name.BaseName

    $project_infos.UProjectPath = Resolve-Path ( Join-Path -Path $project_infos.Folder -ChildPath $u_project_name.Name )

    return $project_infos
}