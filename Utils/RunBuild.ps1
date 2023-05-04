function RunBuild( [string[]] $arguments )
{
    $Process = Start-Process -FilePath $global:context.BuildPath -ArgumentList $arguments -NoNewWindow -PassThru -Wait
    return $Process.ExitCode
}