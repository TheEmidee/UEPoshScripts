## UE Posh Scripts

This is a powershell module that aims at helping interact with an unreal project to easily do things like closing the editor, compiling the editor, running a commandlet, running Buildgraph, etc...

## Installation

You can install this as a submodule for example : `git submodule add git@github.com:TheEmidee/UEPoshScripts.git PoshScripts`

## Usage

In your powershell scripts, you need to first import the UEPoshScripts.psm1 module before being able to interact with the helper functions.

You can find an example in the scripts located in the `Tools` directory.

When the module is loaded, in addition to the functions available in the global scope, you also have access to a global object named `context` that gives you access to various properties, such as the engine definition or the project infos.

The module will also load any ps1 files it can find in a folder named `PoshScripts` inside the `Config` folder of the project.

If you want to use the `RunBuildGraph` function, you will need a config file named `Project.ps1` that would look like:

```
$global:ProjectConfig = @{
    BUILDGRAPH_PATH = "BuildScripts\BuildGraph\BuildGraph.xml"
    BUILDGRAPH_SHARED_PROPERTIES = @{
        "PropertyName" = "PropertyValue"
    }
}
```

Now let's say you want to create helper scripts to run buildgraph tasks. One way to do it would be to create a `Scripts` folder in your project folder, then create a `CompileGame.ps1` file in it. Provided there's a buildgraph task named `Compile Game` for example, your script would look like this:

```
Import-Module -Name ( Resolve-Path( Join-Path -Path ( $PSScriptRoot ) -ChildPath "..\PoshScripts\UEPoshScripts.psm1" ) ) -ErrorAction Stop -Force

RunBuildGraph "Compile Game" @{
    "BuildgraphParameter1" = "True"
    "BuildgraphParameter2" = "C:\PublishDirectory"
}
```