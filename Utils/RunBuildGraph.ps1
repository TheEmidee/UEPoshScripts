function RunBuildGraph( [string] $target = "", [hashtable] $extra_properties = @{}, [string] $extra_parameters = "" )
{
    $BuildGraphPath = Join-Path -Path $global:context.ProjectInfos.Folder -ChildPath $global:ProjectConfig.BUILDGRAPH_PATH

    if ( ( Test-Path $BuildGraphPath ) -eq $False ) {
        throw "Impossible to get a correct path to the buildgraph XML file"
    }

    $extension = (Split-Path -Path $BuildGraphPath -Leaf).Split(".")[1];

    if ( $extension -ne "xml" ) {
        throw "The buildgraph file is not a XML file : $($BuildGraphPath)"
    }

    $arguments = "BuildGraph -script=`"$($BuildGraphPath)`" "
    
    if ( $target -ne "" ) {
        $arguments += "-target=`"$target`""
    }
    
    $common_options = @{
        "Publish_Directory" = $global:context.LocalBuildsFolder
    }

    foreach ($h in $common_options.GetEnumerator()) {
        $arguments += " -set:$($h.Name)=$($h.Value)"
    }

    foreach ($h in $global:context.EnvironmentBuildgraphParameters.GetEnumerator()) {
        $arguments += " -set:$($h.Name)=$($h.Value)"
    }

    foreach ($h in $extra_properties.GetEnumerator()) {
        $arguments += " -set:$($h.Name)=$($h.Value)"
    }

    $arguments += " -Project=$($global:context.ProjectInfos.UProjectPath)"
    $arguments += " $($extra_parameters)"

    return RunUAT $arguments
}