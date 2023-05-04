function Copy-File {
    # ref: https://stackoverflow.com/a/55527732/3626361
    param([string]$From, [string]$To)

    try {
        $job = Start-BitsTransfer -Source $From -Destination $To `
            -Description "Moving: $From => $To" `
            -DisplayName "Backup" -Asynchronous

        # Start stopwatch
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Progress -Activity "Connecting..."

        while ($job.JobState.ToString() -ne "Transferred") {
            switch ($job.JobState.ToString()) {
                "Connecting" {
                    break
                }
                "Transferring" {
                    $pctcomp = ($job.BytesTransferred / $job.BytesTotal) * 100
                    $elapsed = ($sw.elapsedmilliseconds.ToString()) / 1000

                    if ($elapsed -eq 0) {
                        $xferrate = 0.0
                    }
                    else {
                        $xferrate = (($job.BytesTransferred / $elapsed) / 1mb);
                    }

                    if ($job.BytesTransferred % 1mb -eq 0) {
                        if ($pctcomp -gt 0) {
                            $secsleft = ((($elapsed / $pctcomp) * 100) - $elapsed)
                        }
                        else {
                            $secsleft = 0
                        }

                        Write-Progress -Activity ("Copying file '" + ($From.Split("\") | Select-Object -last 1) + "' @ " + "{0:n2}" -f $xferrate + "MB/s") `
                            -PercentComplete $pctcomp `
                            -SecondsRemaining $secsleft
                    }
                    break
                }
                "Transferred" {
                    break
                }
                Default {
                    throw $job.JobState.ToString() + " unexpected BITS state."
                }
            }
        }

        $sw.Stop()
        $sw.Reset()
    }
    finally {
        Complete-BitsTransfer -BitsJob $job
        Write-Progress -Activity "Completed" -Completed
    }
}

function Remove-AllSubFolders() {
    param (
        [string]$ParentFolder
    )

    if (Test-Path -Path $ParentFolder) {
        Get-ChildItem -Path $ParentFolder -Directory | ForEach-Object ($_) { Remove-Item $_.fullname -Force -Recurse }
    }
}