function ExportJenkinsFile( [string] $TemplateFileName, [ string ] $OutputFilePath, [ hashtable ] $TokenReplacementMap = @{} ) {
    $TemplateFolder = $global:JenkinsConfig.TEMPLATES_FOLDER
    $TemplateFilePath = Join-Path -Path $TemplateFolder -ChildPath $TemplateFileName
    $TemplateContent = Get-Content -Raw -Path $TemplateFilePath

    $GroovyTemplatesFolder = Join-Path -Path $TemplateFolder -ChildPath "GroovyTemplates"
    $GroovyTemplates = Get-ChildItem -Path $GroovyTemplatesFolder

    # Replace all tokens of the form __XXX__ by the content of the groovy template with the same name
    foreach ( $GroovyTemplate in $GroovyTemplates ) {
        $GroovyTemplateFileName = $GroovyTemplate.BaseName
        $TemplateContent = $TemplateContent -replace $GroovyTemplateFileName, ( Get-Content -Path $GroovyTemplate.FullName -Raw )
    }

    # Now replace all the tokens @@XXX@@ by what's inside $TokenReplacementMap
    $Pattern = [regex]::Escape('@@') + '(\w+)' + [regex]::Escape('@@')
    $TemplateContent = $TemplateContent -replace $Pattern, { $TokenReplacementMap[$_.Groups[1].Value] }

    Set-Content -Path $OutputFilePath -Value $TemplateContent
}