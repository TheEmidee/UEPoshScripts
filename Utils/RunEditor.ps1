function RunEditor( [string[]] $arguments )
{
    $all_arguments = @( $global:context.ProjectInfos.UProjectPath ) + $arguments
    $Process = Start-Process -FilePath $global:context.EditorPath -ArgumentList $all_arguments
    return $Process.ExitCode
}