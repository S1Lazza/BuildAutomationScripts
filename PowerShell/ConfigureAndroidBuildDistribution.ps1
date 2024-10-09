# --- Script to update all the needed setting for an Android distribution build ---

function Update-ConfigSetting {
        param (
        [string]$filePath,
        [string]$searchSetting,
        [string]$targetSetting
    )

    # --- Attempt to read, modify, and write the config file --- 
    try {
    # --- Read the file and replace the line if it matches the search string --- 
    (Get-Content -Path $filePath) | ForEach-Object {
        if ($_ -match $searchSetting) {
            # --- Replace the line --- 
            Write-Host "Replacing line: $_"
            $_ = $targetSetting
        }

        # --- Write the modified content back to the file --- 
        $_  
    } | Set-Content -Path $filePath -ErrorAction Stop  
    Write-Host "Updated setting '$searchSetting' to '$targetSetting' in $filePath."
    }
    
    catch {
    Write-Error "Failed to update the setting '$searchSetting' in $filePath. Error: $_"
    }   
}

# --- Define the config file path ---
# --- The file to point to is DefaultEngine.ini
$configFilePath = "PathToConfigFile"
$backupFilePath = "${configFilePath}.bak"

# --- Check if the path is valid --- 
if (-not (Test-Path -Path $path)) {
    Write-Error "The specified path '$path' is invalid. Stopping script execution."
    exit 1
}

# --- OPTIONAL: assuming the overriding of the setting is needed only for the build you may want to keep the OG file to replace it back later in the pipeline
# --- Same can be achieve with a revert command on the file after the build is completed (successful or not)
Copy-Item -Path $filePath -Destination "${filePath}.bak"

# --- Set Project Configuration Variables ---
$distributionSetting = "ForDistribution"
$newDistributionSetting = "ForDistribution=True"

$targetSDK = "TargetSDKVersion"
$newTargetSDK = "TargetSDKVersion=32"

# --- Build number is defined by the CI/CD environment, using here what Jenkins provides by default ---
# --- Required to allow correct install on Android devices ---
$storeVersion = "StoreVersion"
$newStoreVersion = Join-Path $storeVersion -ChildPath ("=" + $ENV:BUILD_NUMBER)


# --- Update Distribution Setting ---
Update-ConfigSetting -filePath $configFilePath `
                     -searchSetting $distributionSetting `
                     -targetSetting $newDistributionSetting `

# --- Update Target SDK ---
Update-ConfigSetting -filePath $configFilePath `
                     -searchSetting $targetSDK `
                     -targetSetting $newTargetSDK `

# --- Update Store version ---
Update-ConfigSetting -filePath $configFilePath `
                     -searchSetting $storeVersion `
                     -targetSetting $newStoreVersion `

Write-Host "Configuration updates completed."