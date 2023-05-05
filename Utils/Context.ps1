class Context
{
    [String] $UATPath;
    [String] $UBTPath;
    [String] $BuildPath;
    [String] $EditorPath;
    $EngineDefinition;
    $ProjectInfos;
    [String] $LocalBuildsFolder;
    [String] $BuildGraphPath;
    [String] $Environment;

    Context() 
    {
        $this.ProjectInfos = Get-ProjectInfos
        $this.ProjectInfos.DumpToHost()
        
        $this.LocalBuildsFolder = Join-Path -Path $this.ProjectInfos.Folder -ChildPath "Saved\LocalBuilds"
        
        $this.EngineDefinition = Get-EngineDefinition( $this.ProjectInfos.UProjectPath )

        if ( [string]::IsNullOrWhiteSpace( $this.EngineDefinition.Path ) ) {
            throw "Impossible to get a correct path to a UE installation"
        }

        if ( ( Test-Path $this.EngineDefinition.Path ) -eq $False ) {
            throw "Impossible to get a correct path to a UE installation"
        }

        $this.EngineDefinition.DumpToHost()

        $this.UATPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Engine\Build\BatchFiles\RunUAT.bat"
        $this.UBTPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"
        $this.BuildPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Engine\Build\BatchFiles\Build.bat"

        if ( ( Test-Path $this.UATPath ) -eq $False ) {
            throw "Impossible to get a correct path to RunUAT.bat"
        }

        if ( ( Test-Path $this.UBTPath ) -eq $False ) {
            throw "Impossible to get a correct path to UnrealBuildTool.exe"
        }

        $EditorFileName = "UnrealEditor"

        $EditorFileName = "$($EditorFileName).exe"

        $this.EditorPath = Join-Path -Path $this.EngineDefinition.Path -ChildPath "Engine\Binaries\Win64\$($EditorFileName)"
    }

    [String] GetVRClientDefaultAddress() 
    {
        if ( $this.ConfigJSON.EnvironmentParameters )
        {
            $DefaultIPAddressOverride = $this.ConfigJSON.EnvironmentParameters | Where-Object { $_.Environment -eq $this.Environment } | Select-Object -ExpandProperty DefaultIPAddressOverride

            if ( $null -ne $DefaultIPAddressOverride )
            {
                return $DefaultIPAddressOverride
            }
        }

        return $this.ConfigJSON.DefaultIPAddress
    }
}