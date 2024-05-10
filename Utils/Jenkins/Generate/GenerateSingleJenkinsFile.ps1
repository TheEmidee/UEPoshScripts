# . "$PSScriptRoot\GetBuildGraphJSON.ps1"
# . "$PSScriptRoot\GetGroovyJobsFromBuildGraphJSON.ps1"
# . "$PSScriptRoot\ExportJenkinsFile.ps1"

function GenerateSingleJenkinsFile( [String] $TemplateFileName, [String] $OutputFolder, [String] $BuildgraphTargetName, [hashtable] $BuildgraphPropertyMap, [hashtable] $TokenReplacementMap = @{} ) {

    $JSON = GetBuildGraphJSON $BuildgraphTargetName $BuildgraphPropertyMap
    $GroovyJobs_PR = GetGroovyJobsFromBuildGraphJSON $JSON $BuildgraphPropertyMap
    $TokenReplacementMap += @{ 
        "JOB_DEPENDENCIES" = $GroovyJobs_PR;
    }

    $OutputFile = Join-Path -Path $OutputFolder -ChildPath "$($TemplateFileName)"
    ExportJenkinsFile "$($TemplateFileName).template" $OutputFile $TokenReplacementMap
}