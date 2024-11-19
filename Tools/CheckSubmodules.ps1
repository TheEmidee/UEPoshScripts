Import-Module -Name ( Resolve-Path( Join-Path -Path ( $PSScriptRoot ) -ChildPath "..\UEPoshScripts.psm1" ) ) -ErrorAction Stop -Force

function Get-SubmoduleStatus {
    param (
        [string[]]$StatusOutput
    )

    $submodules = @{}
    foreach ($line in $StatusOutput) {
        if ($line -match '^\s*(\w+)\s+([^\s]+)\s+\(?(.*?)\)?$') {
            $commit = $matches[1]
            $path = $matches[2]
            $submodules[$path] = $commit
        }
    }
    return $submodules
}

function Get-DevelopSubmodules {
    $submodules = @{}
    $submodulePaths = git config --file .gitmodules --get-regexp path | ForEach-Object { ($_ -split "\s+")[1] }

    foreach ($path in $submodulePaths) {
        $commit = git rev-parse develop:$path
        if ($commit) {
            $submodules[$path] = $commit
        }
    }
    return $submodules
}

function Get-SubmoduleActualCommit {
    param (
        [string]$SubmodulePath
    )

    Push-Location $SubmodulePath
    try {
        return git rev-parse HEAD
    }
    finally {
        Pop-Location
    }
}

# Get the repository root from the global context
$repoRoot = Split-Path -Parent $global:context.ProjectInfos.UProjectPath
Push-Location $repoRoot

try {
    $currentBranch = git rev-parse --abbrev-ref HEAD

    $currentStatus = git submodule status
    $currentSubmodules = Get-SubmoduleStatus $currentStatus

    Write-Host "Getting develop branch submodule information..." -ForegroundColor Cyan
    $developSubmodules = Get-DevelopSubmodules

    Write-Host "`nSubmodule Comparison Results:`n" -ForegroundColor Cyan
    Write-Host ("Format: [Path] Current Branch ({0}) -> Develop`n" -f $currentBranch) -ForegroundColor Cyan

    $mismatchCount = 0
    foreach ($path in $currentSubmodules.Keys) {
        $currentCommit = $currentSubmodules[$path]
        $developCommit = $developSubmodules[$path]
        $actualCommit = Get-SubmoduleActualCommit $path

        $isRecordMatch = $currentCommit -eq $developCommit
        $isActualMatch = $actualCommit.StartsWith($currentCommit)

        if ($isRecordMatch -and $isActualMatch) {
            Write-Host "$path" -NoNewline -ForegroundColor Green
            Write-Host ": MATCH ($currentCommit)"
        } else {
            $mismatchCount++
            Write-Host "$path" -NoNewline -ForegroundColor Red
            Write-Host ": DIFFERENT"

            if (-not $isActualMatch) {
                Write-Host "  Working directory is at different commit!" -ForegroundColor Yellow
                Write-Host ("  Expected: {0}" -f $currentCommit)
                Write-Host ("  Actual:   {0}" -f $actualCommit)
            }

            if (-not $isRecordMatch) {
                Write-Host ("  {0}: {1}" -f $currentBranch, $currentCommit)
                Write-Host ("  develop: {0}" -f $developCommit)
            }
        }
    }

    Write-Host "`nSummary:" -ForegroundColor Cyan
    if ($mismatchCount -eq 0) {
        Write-Host "All submodules match develop branch and are at their expected commits! ✓" -ForegroundColor Green
    } else {
        Write-Host ("Found {0} submodule(s) with issues." -f $mismatchCount) -ForegroundColor Yellow
    }
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
finally {
    Pop-Location
}