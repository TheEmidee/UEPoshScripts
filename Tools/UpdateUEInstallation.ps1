# This script aims at updating a local Unreal Engine build with a new one from a remote location
# Prerequisites for this script to work:
# - $RemoteFolder must point to a folder (can be a network folder) that contains a list of 7z files. Each of these archives is a different engine version which must respect the following naming convention : UEMajor.Minor.Patch.JenkinsBuild. For ex : UE5.4.4.96.7z
# - $LocalFolder must point to the folder of the engine installation.
# - The local engine folder must have a file named JenkinsBuild.version in the folder Engine\Build that indicates the jenkins version (the 96 from above)

# What this script does : 
# - A check is made between the version of the engine on the remote location (by parsing its file name) and the version of the local location (by parsing Build.version and JenkinsBuild.version)
# - If the local version is equal or newer than the remote version, nothing is done
# - Else the local folder is deleted, then the remote archive is copied locally, then extracted where the previous installation was, and eventually the archive is deleted

param (
    [Boolean] $unattended = $False,
    [String] $RemoteFolder = "",
    [String] $LocalFolder = ""
)

Write-Host "Parameters :"
Write-Host "unattended : $($unattended)"
Write-Host "RemoteFolder : $($RemoteFolder)"
Write-Host "LocalFolder : $($LocalFolder)"
Write-Host ""

# --- FUNCTIONS ---

function Get-FirstFolderContainingString {
    param (
        [string]$Path,      # The path to search, defaults to the current directory
        [string]$SearchString     # The string to search for in folder names
    )

    # Get all directories recursively, filter by the name containing the search string, and return the first match
    Get-ChildItem -Path $Path -Directory -Recurse | Where-Object {
        $_.Name -like "*$SearchString*"
    } | Select-Object -First 1 -ExpandProperty FullName
}

function Export-7ZipArchive {
    param (
        [string]$archivePath,
        [string]$outputFolder
    )

    # Ensure 7z is in the system path
    $sevenZipPath = "7z.exe"
    if (-not (Get-Command $sevenZipPath -ErrorAction SilentlyContinue)) {
        Write-Error "7z.exe not found in PATH. Please ensure 7-Zip is installed and the executable is in your system's PATH."
        return $False
    }

    # Start extraction with multithreading (default 7z behavior)
    $arguments = "x `"$archivePath`" -o`"$outputFolder`" -mmt"
    
    # Start the extraction process
    Write-Host "Extracting archive: $archivePath"
    Start-Process -FilePath $sevenZipPath -ArgumentList $arguments -NoNewWindow -Wait

    Write-Host "Extraction completed: $archivePath"
    return $True
}

function Select-FileFromFolder {
    param (
        [string]$folderPath,
        [Boolean]$unattended
    )

    # Check if the folder exists
    if (-not (Test-Path $folderPath)) {
        Write-Host "The folder path specified does not exist."
        return $null
    }

    # Get all files in the folder, ordered by name descending
    $files = Get-ChildItem -Path $folderPath | Where-Object { -not $_.PSIsContainer } | Sort-Object Name -Descending

    # Check if there are any files
    if ($files.Count -eq 0) {
        Write-Host "No files found in the folder."
        return $null
    }

    if ( $unattended -Eq $False ) {
        # List files with numbers
        for ($i = 0; $i -lt $files.Count; $i++) {
            Write-Host "$i : $($files[$i].Name)"
        }

        # Prompt user to choose a file
        $fileIndex = Read-Host "Enter the number of the file you want to choose"
    } else {
        $fileIndex = 0
    }

    # Validate input
    if ($fileIndex -ge 0 -and $fileIndex -lt $files.Count) {
        return $files[$fileIndex].FullName
    } else {
        Write-Host "Invalid selection."
        return $null
    }
}
Function Remove-Folder {
    param (
        [string]$folderPath,
        [Boolean]$unattended
    )

    Write-Host "Try to delete folder $($folderPath)"

    # Check if the folder exists
    if (Test-Path $folderPath) {
        $canDelete = $true
        if ( $unattended -Eq $false ) {
            # Prompt for confirmation
            $confirmation = Read-Host "Are you sure you want to delete the folder '$folderPath'? (y/n)"
            $canDelete = $confirmation -eq 'y'
        }
        
        if ( $canDelete -eq $true ) {
            # If confirmed, delete the folder
            Remove-Item -Recurse -Force $folderPath
            Write-Host "Folder '$folderPath' has been deleted."
        } else {
            Write-Host "Folder deletion canceled."
        }
    } else {
        Write-Host "Folder does not exist."
    }
}

Function Copy-Archive {
    param (
        [string]$sourceFolder,
        [string]$targetFolder,
        [string]$fileName
    )

    # RoboCopy command to copy the file
    & robocopy.exe $sourceFolder $targetFolder $fileName /J /NOOFFLOAD /R:0 /W:0 /MT /Z

    Write-Host "File copy completed!"
}

function Get-EngineVersionFromFolder( [string] $Folder ) {
    $EnginePath = Join-Path -Path $Folder -ChildPath "Engine"
    $build_version_file_path = Join-Path -Path $EnginePath -ChildPath "Build\Build.version"
    $jenkins_version_file_path = Join-Path -Path $EnginePath -ChildPath "Build\JenkinsBuild.version"

    if ( [System.IO.File]::Exists( $build_version_file_path ) -eq $False ) {
        Write-Warning "Impossible to find the file ${build_version_file_path}"
    } else {
        $ue_json = Get-Content -Raw -Path $build_version_file_path | ConvertFrom-Json
        $revision_number = "0"

        if ( [System.IO.File]::Exists( $jenkins_version_file_path ) -eq $True ) {
            $revision_number = Get-Content -Path $jenkins_version_file_path
            return [Version]::new( $ue_json.MajorVersion, $ue_json.MinorVersion, $ue_json.PatchVersion, $revision_number )
        }

        return [Version]::new( $ue_json.MajorVersion, $ue_json.MinorVersion, $ue_json.PatchVersion )
    }

    return [Version]::new( 0, 0, 0 )
}

function Get-EngineVersionFromArchiveName( [string] $ArchiveName ) {
    $regex = [regex]::new('UE(\d+)\.(\d+)\.(\d+)\.(\d+)(.*)\.7z')

    if ($regex.IsMatch($ArchiveName)) {
        $regex_matches = $regex.Match($ArchiveName)

        # Extract the groups and construct the version number
        $major = $regex_matches.Groups[1].Value
        $minor = $regex_matches.Groups[2].Value
        $patch = $regex_matches.Groups[3].Value
        $build = $regex_matches.Groups[4].Value

        return [Version]::new( $major, $minor, $patch, $build )
    } else {
        return [Version]::new( 0, 0, 0 )
    }
}

# --- Execution ---

Write-Host "Remote Path : $($RemoteFolder)"
Write-Host "Local Path : $($LocalFolder)"

$selectedFile = Select-FileFromFolder -folderPath $RemoteFolder -unattended $unattended

if ( $null -eq $selectedFile) {
    Exit
}

$file = Get-Item $selectedFile

Write-Host "Selected File : $($selectedFile)"

$localEngineVersion = Get-EngineVersionFromFolder -Folder $LocalFolder
Write-Host "Local engine version : $($localEngineVersion)"

$remoteEngineVersion = Get-EngineVersionFromArchiveName -ArchiveName $file.Name
Write-Host "Remote engine version : $($remoteEngineVersion)"

if ( $localEngineVersion -ge $remoteEngineVersion ) {
    Write-Host "The local version of the engine is equal or newer than the remote version"
    exit
}

Remove-Folder -folderPath $LocalFolder -unattended $unattended

$localRootFolder = Split-Path -Path $LocalFolder -Parent
$localArchivePath = Join-Path -Path $localRootFolder -ChildPath $file.Name

if ( ( Test-Path -Path $localArchivePath ) -eq $False ) {
    Copy-Archive $file.DirectoryName $localRootFolder $file.Name
} else {
    Write-Host "The archive already exists"
}

if (Test-Path $localArchivePath) {
    Export-7ZipArchive -archivePath $localArchivePath -outputFolder $LocalFolder
} else {
    Write-Error "File not found: $localArchivePath"
}

Remove-Item $localArchivePath