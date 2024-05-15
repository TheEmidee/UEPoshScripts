class ProjectSavedFolders
{
    [String] $BuildGraph;
    [String] $Jenkins;
    [String] $Temp;
    [String] $Tests;
    [String] $LocalBuilds;
    [String] $StagedBuilds;

    ProjectSavedFolders(
        [String] $SavedFolder
    ) {
        # Don't use Resolve-Path as the folders may not exist
        $this.BuildGraph = Join-Path -Path $SavedFolder -ChildPath "BuildGraph"
        $this.Jenkins = Join-Path -Path $SavedFolder -ChildPath "Jenkins"
        $this.Temp = Join-Path -Path $SavedFolder -ChildPath "Temp"
        $this.Tests = Join-Path -Path $SavedFolder -ChildPath "Tests"
        $this.LocalBuilds = Join-Path -Path $SavedFolder -ChildPath "LocalBuilds"
        $this.StagedBuilds = Join-Path -Path $SavedFolder -ChildPath "StagedBuilds"
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
        $this.Config = Join-Path -Path $RootFolder -ChildPath "Config"
        $this.Saved = Join-Path -Path $RootFolder -ChildPath "Saved"
        $this.SavedFolders = [ProjectSavedFolders]::new( $this.Saved )
    }
}

class ProjectInfos
{
    [String] $RootFolder;
    [String] $ProjectName;
    [String] $UProjectPath;
    [ProjectFolders] $ProjectFolders;
    [bool] $IsEngine;

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
        $this.UProjectPath = $UProjectFile.FullName

        $this.IsEngine = ( Test-Path $This.UProjectPath ) -eq $False

        if ( $this.IsEngine -eq $False ) {
            $this.ProjectName = $UProjectFile.BaseName
        } else {
            $EnginePath = Resolve-Path ( Join-Path -Path $PSScriptRoot -ChildPath "../../../" )
    
            if ( Test-Path -Path ( "$($EnginePath)/Setup.bat" ) ) {
                $this.ProjectName = "Engine"
                $this.RootFolder = $EnginePath
            } else {
                exit 1
            }
        }

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