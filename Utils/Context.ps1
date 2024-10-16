class Context
{
    [String] $UATPath;
    [String] $UBTPath;
    [String] $BuildPath;
    [String] $EditorPath;
    [String] $PoshScriptsConfigFolder;
    $EngineDefinition;
    $ProjectInfos;
    
    Context() 
    {
        $this.ProjectInfos = Get-ProjectInfos
        $this.ProjectInfos.DumpToHost()

        $this.EngineDefinition = Get-EngineDefinition( $this.ProjectInfos )

        if ( [string]::IsNullOrWhiteSpace( $this.EngineDefinition.Path ) ) {
            throw "Impossible to get a correct path to a UE installation"
        }

        if ( ( Test-Path $this.EngineDefinition.Path ) -eq $False ) {
            throw "Impossible to get a correct path to a UE installation"
        }

        $this.EngineDefinition.DumpToHost()

        $this.UATPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Build\BatchFiles\RunUAT.bat"
        $this.UBTPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"
        $this.BuildPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Build\BatchFiles\Build.bat"

        if ( ( Test-Path $this.UATPath ) -eq $False ) {
            throw "Impossible to get a correct path to RunUAT.bat"
        }

        if ( ( $this.ProjectInfos.IsEngine -eq $False ) -and ( Test-Path $this.UBTPath ) -eq $False ) {
            throw "Impossible to get a correct path to UnrealBuildTool.exe"
        }

        $this.EditorPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Binaries\Win64\UnrealEditor.exe"

        $ConfigFolder = "Config\PoshScripts"

        $this.PoshScriptsConfigFolder = Join-Path $this.ProjectInfos.RootFolder -ChildPath $ConfigFolder
    }
}