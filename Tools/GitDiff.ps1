# Source : https://gist.github.com/Panakotta00/c90d1017b89b4853e8b97d13501b2e62

Import-Module -Name ( Resolve-Path( Join-Path -Path ( $PSScriptRoot ) -ChildPath "..\UEPoshScripts.psm1" ) ) -ErrorAction Stop -Force

for ($i = 0; $i -lt $args.length; $i++) {
    $args[$i] = Resolve-Path $args[$i]
    $TempFile = New-TemporaryFile
    Copy-Item $args[$i] -Destination $TempFile
    $args[$i] = $TempFile
}

RunEditorAndWait @(
    $global:context.ProjectInfos.UProjectPath,
    "-diff"
    $args[ 0 ],
    $args[ 1 ]
)