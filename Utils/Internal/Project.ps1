class ProjectSavedFolders
{
    [String] $BuildGraph;
    [String] $Jenkins;
    [String] $Temp;
    [String] $Tests;

    ProjectSavedFolders(
        [String] $SavedFolder
    ) {
        $this.BuildGraph = Resolve-Path ( Join-Path -Path $SavedFolder -ChildPath "BuildGraph" )
        $this.Jenkins = Resolve-Path ( Join-Path -Path $SavedFolder -ChildPath "Jenkins" )
        $this.Temp = Resolve-Path ( Join-Path -Path $SavedFolder -ChildPath "Temp" )
        $this.Tests = Resolve-Path ( Join-Path -Path $SavedFolder -ChildPath "Tests" )
    }
}

class ProjectFolders
{
    [String] $Config;
    [String] $Saved;
    [ProjectSavedFolders] $SavedFolders;

    ProjectFolders(
        [String] $RootFolder
    ) {
        $this.Config = Resolve-Path ( Join-Path -Path $RootFolder -ChildPath "Config" )
        $this.Saved = Resolve-Path ( Join-Path -Path $RootFolder -ChildPath "Saved" )
        $this.SavedFolders = [ProjectSavedFolders]::new( $this.Saved )
    }
}

class ProjectInfos
{
    [String] $RootFolder;
    [String] $ProjectName;
    [String] $UProjectPath;
    [ProjectFolders] $ProjectFolders;

    ProjectInfos() {
        $this.RootFolder = Resolve-Path ( Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\" )
        $u_project_name = Get-ChildItem $this.RootFolder -File '*.uproject'

        if ( $null -eq $u_project_name ) {
            throw "Impossible to find a uproject file"
        }

        $this.ProjectName = $u_project_name.BaseName
        $this.UProjectPath = Resolve-Path ( Join-Path -Path $this.RootFolder -ChildPath $u_project_name.Name )
        $this.ProjectFolders = [ProjectFolders]::new( $this.RootFolder )
    }

    [void] DumpToHost(){
        Write-Host "----- Project infos -----"
        Write-Host " * Folder : $($this.RootFolder)"
        Write-Host " * ProjectName : $($this.ProjectName)"
        Write-Host " * UProjectPath : $($this.UProjectPath)"
        Write-Host "----- Project infos -----"
        Write-Host ""
    }
}

function Get-ProjectInfos() {
    return [ProjectInfos]::new()
}