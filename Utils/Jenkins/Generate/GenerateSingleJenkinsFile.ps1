function GenerateSingleJenkinsFile( [String] $TemplateFileName, [String] $BuildgraphTargetName, [hashtable] $BuildgraphPropertyMap, [hashtable] $TokenReplacementMap = @{} ) {

    $JSON = GetBuildGraphJSON $BuildgraphTargetName $BuildgraphPropertyMap
    $GroovyJobs_PR = GetGroovyJobsFromBuildGraphJSON $JSON $BuildgraphPropertyMap
    $TokenReplacementMap += @{ 
        "JOB_DEPENDENCIES" = $GroovyJobs_PR;
    }

    $OutputFolder = $global:JenkinsConfig.OUTPUT_FOLDER
    $OutputFile = Join-Path -Path $OutputFolder -ChildPath "$($TemplateFileName)"
    
    ExportJenkinsFile "$($TemplateFileName).template" $OutputFile $TokenReplacementMap
}