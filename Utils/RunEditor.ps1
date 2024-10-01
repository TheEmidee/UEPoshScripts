function RunEditor {
    param (
        [string[]] $arguments
     )

    
    $all_arguments = @( $global:context.ProjectInfos.UProjectPath ) + $arguments

    $process = Start-Process -FilePath $global:context.EditorPath -ArgumentList $all_arguments
    return $process.ExitCode
}

function RunEditorAndWait {
    param (
        [string[]] $arguments
     )

    
    $all_arguments = @( $global:context.ProjectInfos.UProjectPath ) + $arguments

    $process = Start-Process -FilePath $global:context.EditorPath -ArgumentList $all_arguments -Wait
    return $process.ExitCode
}