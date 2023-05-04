function Stop-Processes {
    param(
        [parameter(Mandatory=$true)] $processName,
                                     $timeout = 5
    )

    Write-Host "Will stop process $($processName)"

    $processList = Get-Process $processName -ErrorAction SilentlyContinue
    if ($processList) {
        # Try gracefully first
        $processList.CloseMainWindow() | Out-Null

        # Wait until all processes have terminated or until timeout
        for ($i = 0 ; $i -le $timeout; $i ++){
            $AllHaveExited = $True
            $processList | % {
                $process = $_
                If (!$process.HasExited){
                    $AllHaveExited = $False
                }
            }
            If ($AllHaveExited -eq $True){
                Return
            }
            Start-Sleep 1
        }
        # Else: kill
        $processList | Stop-Process -Force
    }
}