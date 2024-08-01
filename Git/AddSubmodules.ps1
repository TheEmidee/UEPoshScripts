# Declare a hashtable with submodule URLs as keys and submodule names as values
$submodules = @{
    "git@github.com:TheEmidee/UECommonGame.git" = "Plugins/CommonGame";
    "git@github.com:TheEmidee/UECommonLoadingScreen.git" = "Plugins/CommonLoadingScreen";
    "git@github.com:TheEmidee/UECommonUser.git" = "Plugins/CommonUser";
    "git@github.com:TheEmidee/UECoreExtensions.git" = "Plugins/CoreExtensions";
    "git@github.com:TheEmidee/UEDataValidationExtensions.git" = "Plugins/DataValidationExtensions";
    "git@github.com:TheEmidee/UEGameBaseFramework.git" = "Plugins/GameBaseFramework";
    "git@github.com:TheEmidee/UEGameSettings.git" = "Plugins/GameSettings";
    "git@github.com:TheEmidee/UEMapCheckvalidation.git" = "Plugins/MapCheckvalidation";
    "git@github.com:TheEmidee/UEModularGameplayActors.git" = "Plugins/ModularGameplayActors";
    "git@github.com:TheEmidee/UENamingConventionValidation.git" = "Plugins/NamingConventionValidation";
    "git@github.com:TheEmidee/UEUIExtension.git" = "Plugins/UIExtension";
    
    "git@github.com:ProjectBorealis/UEGitPlugin" = "Plugins/GitPlugin";
}

# Path to the Git repository folder where you want to add the submodules
$gitRepoPath = Resolve-Path ( Join-Path $PSScriptRoot "..\..\" )

Write-Host $gitRepoPath

# Navigate to the Git repository folder
Set-Location -Path $gitRepoPath

# # Iterate over each entry in the hashtable and add the submodule to the Git repository
foreach ($submodule in $submodules.GetEnumerator()) {
    $url = $submodule.Key
    $name = $submodule.Value

    # Add the submodule
    git submodule add $url $name
}

# Optional: Initialize and update the submodule
git submodule update --init --recursive

# # Go back to the original location (if needed)
Pop-Location