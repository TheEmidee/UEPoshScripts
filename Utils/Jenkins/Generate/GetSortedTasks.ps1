# Use a topological sort using Kahn's algorithm to return sorted tasks
function GetSortedTasks {
    param(
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.HashSet[string]]$tasks,

        [Parameter(Mandatory=$true)]
        [array]$dependencies
    )

    $inDegree = @{}
    $queue = New-Object System.Collections.Queue
    
    $result = [ Collections.Generic.List[ System.Collections.Generic.HashSet[ string ] ] ]::new()

    # Initialize in-degree for each task
    foreach ($task in $tasks) {
        $inDegree[$task] = 0
    }

    # Update from the original algorithm : have a list of tasks with no dependencies and add them all at the end
    $TasksWithNoDependencies = [ System.Collections.Generic.HashSet[ string ] ]::new()
    
    foreach ( $Task in $tasks ) {
        [void] $TasksWithNoDependencies.Add( $Task )
    }

    # Calculate in-degree for each task
    foreach ($dependency in $dependencies) {
        $inDegree[$dependency[1]]++
        [void ] $TasksWithNoDependencies.Remove($dependency[0])
    }

    foreach ($Task in $TasksWithNoDependencies) {
        $inDegree.Remove( $Task )
        [void ]$tasks.Remove( $Task )
    }

    # Enqueue tasks with in-degree zero
    foreach ($task in $tasks) {
        if ($inDegree[$task] -eq 0) {
            $queue.Enqueue($task)
        }
    }

    # Process tasks
    while ($queue.Count -ne 0) {
        $parallelTasks = [ System.Collections.Generic.HashSet[ string ] ]::new()

        # Process all tasks with in-degree zero in parallel
        $tasksToProcess = $queue.ToArray()
        foreach ($current in $tasksToProcess) {
            [ void ] $parallelTasks.Add( $current )

            # Reduce in-degree for dependent tasks
            foreach ($dependency in $dependencies) {
                if ($dependency[0] -eq $current) {
                    $inDegree[$dependency[1]]--
                    if ($inDegree[$dependency[1]] -eq 0) {
                        $queue.Enqueue($dependency[1])
                    }
                }
            }

            $queue.Dequeue()  # Remove the processed task
        }

        [ void ] $result.Add( $parallelTasks.Clone() )
    }

    [ void ] $result.Add( $TasksWithNoDependencies.Clone() )

    return $result
}