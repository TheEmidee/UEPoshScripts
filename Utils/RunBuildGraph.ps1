function RunBuildGraph( [string] $target = "", [hashtable] $extra_properties = @{}, [string] $extra_parameters = "" )
{
    $BuildGraphPath = Join-Path -Path $global:context.ProjectInfos.Folder -ChildPath $global:ProjectConfig.BUILDGRAPH_PATH

    if ( ( Test-Path $BuildGraphPath ) -eq $False ) {
        throw "Impossible to get a correct path to the buildgraph XML file"
    }

    $extension = ( Split-Path -Path $BuildGraphPath -Leaf ).Split(".")[1];

    if ( $extension -ne "xml" ) {
        throw "The buildgraph file is not a XML file : $($BuildGraphPath)"
    }

    $scripts_dir = Join-Path -Path $global:context.ProjectInfos.Folder -ChildPath $global:ProjectConfig.AUTOMATION_SCRIPTS_DIRECTORY

    $arguments = "BuildGraph -ScriptDir=`"$($scripts_dir)`" -script=`"$($BuildGraphPath)`" "

    if ( $target -ne "" ) {
        $arguments += " -target=`"$target`""
    }
    
    foreach ( $h in $global:ProjectConfig.BUILDGRAPH_SHARED_PROPERTIES.GetEnumerator() ) {
        $arguments += " -set:$($h.Name)=$($h.Value)"
    }

    foreach ( $h in $extra_properties.GetEnumerator() ) {
        $arguments += " -set:$($h.Name)=$($h.Value)"
    }

    $arguments += " -Project=$($global:context.ProjectInfos.UProjectPath)"
    $arguments += " $($extra_parameters)"

    return RunUAT $arguments
}