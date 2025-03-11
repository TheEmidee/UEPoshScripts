function GenerateSingleJenkinsFile( [String] $TemplateFileName, [String] $BuildgraphTargetName, [hashtable] $BuildgraphPropertyMap, [hashtable] $TokenReplacementMap = @{}, [String] $OutputFileOverride = "" ) {

    $JSON = GetBuildGraphJSON $BuildgraphTargetName $BuildgraphPropertyMap
    $GroovyJobs_PR = GetGroovyJobsFromBuildGraphJSON $JSON $BuildgraphPropertyMap
    $TokenReplacementMap += @{ 
        "JOB_DEPENDENCIES" = $GroovyJobs_PR;
    }

    $OutputFolder = $global:JenkinsConfig.OUTPUT_FOLDER

    $OutputFileName = $OutputFileOverride

    if ( $OutputFileName -eq "" ) {
        $OutputFileName = $TemplateFileName
    }

    $OutputFile = Join-Path -Path $OutputFolder -ChildPath "$($OutputFileName)"
    
    ExportJenkinsFile "$($TemplateFileName).template" $OutputFile $TokenReplacementMap
}