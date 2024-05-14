function GetGroovyJobsFromBuildGraphJSON( $JSON, [hashtable] $Properties = @{}, [array] $PropertyToParameters = @(), [bool] $RunAsSingleNode = $True ) {
    # Generate a pipeline object based on the JSON
    $PlatformBuildPipeline = @{}
    $PlatformJobToGroupMap = @{}
    $Platforms = New-Object System.Collections.Generic.HashSet[string]

    $PropertiesInlined = ""
    foreach ($h in $Properties.GetEnumerator() | Sort-Object Name) {
        $Value = $h.Value

        # Substitute the value by the jenkins parameter if one exists
        if ( $PropertyToParameters.Contains( $h.Name ) ) {
            $Value = "`${propertyMap[`"$($h.Name)`"]}"
        }

        $PropertiesInlined += "-set:$($h.Name)=$($Value) "
    }

    foreach ( $Group in $JSON.Groups ) {
        $PlatformName = $Group."Agent Types"[ 0 ]
        $PlatformName = $PlatformName -replace "_Licensee" -replace ""

        [void] $Platforms.Add( $PlatformName )
        
        $BuildGroup = @{
            Name = $Group.Name;
            Jobs = @();
        }

        foreach ( $Node in $Group.Nodes ) {
            
            $BuildJob = @{
                Name = $Node.Name;
                Needs = @();
            }
            
            $BuildJob.Needs = $Node.DependsOn.Split(";")
            if ($BuildJob.Needs.Length -eq 1 -and $BuildJob.Needs[0] -eq "")  {
                $BuildJob.Needs = @()
            }

            $BuildGroup.Jobs += $BuildJob

            if ( $PlatformJobToGroupMap.ContainsKey( $PlatformName ) ) {
                $PlatformJobToGroupMap[ $PlatformName ][ $BuildJob.Name ] = $BuildGroup.Name
            } else {
                $Item = @{}
                $Item[ $BuildJob.Name ] = $BuildGroup.Name

                $PlatformJobToGroupMap[ $PlatformName ] = $Item;
            }
        }

        if ( $PlatformBuildPipeline.ContainsKey( $PlatformName ) ) {
            $PlatformBuildPipeline[ $PlatformName ] += $BuildGroup
        } else {
            $PlatformBuildPipeline[ $PlatformName ] = @( $BuildGroup )
        }
    }

    $PlatformJobs = ""

    foreach ( $Platform in $Platforms ) {
        $JobToGroupMap = $PlatformJobToGroupMap[ $Platform ]
        $BuildPipeline = $PlatformBuildPipeline[ $Platform ]

        $Groups = New-Object System.Collections.Generic.HashSet[string]

        $Dependencies = @()
        foreach ( $BuildGroup in $BuildPipeline ) {
            [void] $Groups.Add( $BuildGroup.Name )

            $DependentGroups = New-Object System.Collections.Generic.HashSet[string]
            foreach ( $Job in $BuildGroup.Jobs ) {
                foreach ( $RequiredJob in $Job.Needs ) {
                    $RequiredJobGroupName = $JobToGroupMap[ $RequiredJob ]
                    [void] $DependentGroups.Add( $RequiredJobGroupName )
                }
            }

            [void] $DependentGroups.Remove( $BuildGroup.Name )

            foreach ( $RequiredJobGroupName in $DependentGroups ) {
                $Dependencies += , @( $BuildGroup.Name, $RequiredJobGroupName )
            }
        }

        $ParallelGroups = GetSortedTasks $Groups $Dependencies

        $LastIndex = $ParallelGroups.Length - 1

        for ( $i = $LastIndex; $i -ge 0; $i-- ) {
            $Groups = $ParallelGroups[ $i ]

            # Powershell unrolls elements of an array when it returns it from a function
            # Since we're iterating the result backwards, stop as soon as we have an unrolled element
            if ( $Groups -is [ String ] ) {
                break
            }

            $ParallelGroupsStr = @()
            $TasksStr = ""

            foreach ( $Group in $Groups ) {
                foreach ( $BuildGroup in $BuildPipeline ) {
                    if ( $BuildGroup.Name -eq $Group ) {
                        $Jobs = @()
                        foreach ( $Job in $BuildGroup.Jobs ) {
                            $Jobs += @"
"{0}"
"@ -f $Job.Name
                        }
                        $TasksStr = @"
[ 
        {0} 
    ]
"@ -f ( $Jobs -join ",`n            " )
                    }
                }

                $GroupsStr = @"
jobs[ "{0}" ] = {{
runBuildGraph( 
    "{1}", 
    {2},
    "{3}",
    properties 
    )
}}
"@ -f $Group, $Group, $TasksStr, $Platform

                $ParallelGroupsStr += ,$GroupsStr
            }

            $ParallelJobs = @"
jobs = [:]
{0}
jobs.failFast = true
parallel jobs
`n
"@ -f ( $ParallelGroupsStr -join "`n" )

            $PlatformJobs += $ParallelJobs
        }
    }

    return @"
def properties = "{0}"
`n
{1}
"@ -f $PropertiesInlined, $PlatformJobs
}