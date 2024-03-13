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
        $ParentDirectory = Get-Item $PSScriptRoot
        $MaxDepth = 5
        $Depth = 0

        while ( $ParentDirectory -and $Depth -lt $MaxDepth -and -not ( Get-ChildItem -Path $ParentDirectory.FullName -Filter "*.uproject" ) ) {
            $ParentDirectory = Get-Item $ParentDirectory.FullName | Get-Item -Path { Split-Path -Parent $_.FullName }
            $Depth++
        }

        if ( -not $ParentDirectory ) {
            throw "Impossible to find a uproject file"
        }

        $this.RootFolder = $ParentDirectory
        $UProjectFile = Get-ChildItem $this.RootFolder -File '*.uproject'

        $this.ProjectName = $UProjectFile.BaseName
        $this.UProjectPath = $UProjectFile.FullName
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