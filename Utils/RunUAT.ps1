function RunUAT( [string[]] $arguments )
{
    $Process = Start-Process -FilePath $global:context.UATPath -ArgumentList $arguments -NoNewWindow -PassThru -Wait
    return $Process.ExitCode
}