function RunUBT( [string[]] $arguments )
{
    $all_arguments = @( $global:context.ProjectInfos.UProjectPath ) + $Arguments
    $Process = Start-Process -FilePath $global:context.UBTPath -ArgumentList $all_arguments -NoNewWindow -Wait
    return $Process.ExitCode
}