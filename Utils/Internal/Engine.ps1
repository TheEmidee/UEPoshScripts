class EngineDefinition
{
    [String] $Path;
    [String] $EngineAssociation;
    [Version] $Version;

    [void] DumpToHost(){
        Write-Host "----- Engine infos -----"
        Write-Host " * Folder : $($this.Path)"
        Write-Host " * EngineAssociation : $($this.EngineAssociation)"
        Write-Host " * Version : $($this.Version)"
        Write-Host "----- Engine infos -----"
        Write-Host ""
    }
}
function Get-ProjectEngineAssociation( [String] $ProjectPath ) {
    $uproject_json = Get-Content -Raw -Path $ProjectPath | ConvertFrom-Json
    return $uproject_json.EngineAssociation
}

function Resolve-EnginePath( [String] $EngineAssociation ) {
    # First check if we are on a CI node
    if ( ( ![string]::IsNullOrWhiteSpace( $env:NODE_UE_ROOT ) ) ) {
        if ( Test-Path $env:NODE_UE_ROOT ) {
            $engine_path = Join-Path -Path $env:NODE_UE_ROOT -ChildPath $EngineAssociation

            if ( Test-Path $engine_path ) {
                return $engine_path
            }

            Write-Warning "Environment variable NODE_UE_ROOT is set, but we could not find a folder at this location : $($engine_path)"
        } else {
            Write-Warning "Environment variable NODE_UE_ROOT is set, but it points to an invalid folder : $($env:NODE_UE_ROOT)"
        }
    }

    try {
        if (Test-Path "HKCU:\SOFTWARE\Epic Games\Unreal Engine\Builds") {
            return Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Epic Games\Unreal Engine\Builds" -Name $EngineAssociation
        }
    } catch {

    }

    if (Test-Path "HKLM:\SOFTWARE\EpicGames\Unreal Engine\$($EngineAssociation)") {
        return (Get-ItemProperty -Path "HKLM:\SOFTWARE\EpicGames\Unreal Engine\$EngineAssociation" -Name "InstalledDirectory").InstalledDirectory;
    }

    # If the engine matches a version regex [45]\.[0-9]+(EA)?, check the Program Files folder.
    if ($EngineAssociation -match "[45]\.[0-9]+(EA)?") {
        if (Test-Path "$env:PROGRAMFILES\Epic Games\$EngineAssociation") {
            return "$env:PROGRAMFILES\Epic Games\$EngineAssociation"
        }
    }

    # If the engine path ends in a \, remove it because it creates problems when the
    # path is passed in on the command line (usually escaping a quote " ...)
    if ($EngineAssociation.EndsWith("\")) {
        $EngineAssociation = $EngineAssociation.Substring(0, $EngineAssociation.Length - 1)
    }

    # If this is an absolute path to an engine, use that.
    if ([System.IO.Path]::IsPathRooted("$EngineAssociation")) {
        if (Test-Path "$EngineAssociation") {
            return $EngineAssociation
        }
    }


    # Otherwise, we couldn't locate the engine.
    Write-Error "Unable to locate engine description by `"$EngineAssociation`" (checked registry, Program Files and absolute path)."
    return $null
}

function Get-EngineVersion( [string] $EnginePath ) {
    $build_version_file_path = Join-Path -Path $EnginePath -ChildPath "Engine\Build\Build.version"
    $jenkins_version_file_path = Join-Path -Path $EnginePath -ChildPath "Engine\Build\JenkinsBuild.version"

    if ( [System.IO.File]::Exists( $build_version_file_path ) -eq $False ) {
        Write-Warning "Impossible to find the file ${build_version_file_path}"
    } else {
        $ue_json = Get-Content -Raw -Path $build_version_file_path | ConvertFrom-Json
        $revision_number = "0"

        if ( [System.IO.File]::Exists( $jenkins_version_file_path ) -eq $True ) {
            $revision_number = Get-Content -Path $jenkins_version_file_path
        }

        return [Version]::new( $ue_json.MajorVersion, $ue_json.MinorVersion, $ue_json.PatchVersion, $revision_number )
    }

    return [Version]::new( 0, 0, 0 )
}

function Get-EngineDefinition( [ProjectInfos] $ProjectInfos ) {
    $engine_definition = [EngineDefinition]::new();

    if ( $ProjectInfos.IsEngine -eq $False ) {
        $engine_definition.EngineAssociation = Get-ProjectEngineAssociation( $ProjectInfos.UProjectPath )
        $engine_definition.Path = Resolve-EnginePath( $engine_definition.EngineAssociation )
    } else {
        $engine_definition.Path = $ProjectInfos.RootFolder
    }

    $engine_definition.Version = Get-EngineVersion( $engine_definition.Path )
    return $engine_definition
}