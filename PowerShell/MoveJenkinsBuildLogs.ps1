# --- Utility script to add log and changelist files from Jenkins to build folder for distribution ---

# --- Copy a file with error handling --- 
function Copy-FileWithLogging {
    param (
        [string]$sourceFile,
        [string]$destinationFile,
        [string]$fileDescription
    )

    if (Test-Path $sourceFile) {
        try {
            Copy-Item -Path $sourceFile -Destination $destinationFile -Force
            Write-Host "$fileDescription copied successfully to $destinationFile."
        }
        catch {
            Write-Error "Failed to copy $fileDescription to $destinationFile. Error: $_"
        }
    }
    else {
        Write-Error "$fileDescription not found at $sourceFile."
    }
}

# --- Set directory path ---
# --- $ENV:JOB_NAME is automatically set by Jenkins --- 
$jenkinsPath = Join-Path -Path "C:\ProgramData\Jenkins\.jenkins\jobs" -ChildPath $ENV:JOB_NAME
$TargetFolder = "PathToBuildDirectory"

# --- Define target file paths ---
# --- $ENV:BUILD_NUMBER is automatically set by Jenkins --- 
$logFile = Join-Path -Path $jenkinsPath -ChildPath ("builds\" + $ENV:BUILD_NUMBER + "\log")
$changelogFile = Join-Path -Path $jenkinsPath -ChildPath ("builds\" + $ENV:BUILD_NUMBER + "\changelog.xml")

# --- Define target file paths ---
$convertLogFile = Join-Path -Path $targetFolder -ChildPath "Log.txt"
$convertChangelogFile = Join-Path -Path $targetFolder -ChildPath "Changelist.txt"

# --- Copy the files to the target directory --- 
$ConvertLogFile = $TargetFolder + "Log.txt"
Copy-Item -Path $LogFile -Destination $ConvertLogFile -Recurse
$ConvertChangelogFile = $TargetFolder + "Changelist.txt"
Copy-Item -Path $ChangelogFile -Destination $ConvertChangelogFile -Recurse

# --- Copy the log and changelog files to the target folder --- 
Copy-FileWithLogging -sourceFile $logFile -destinationFile $convertLogFile -fileDescription "Log file"
Copy-FileWithLogging -sourceFile $changelogFile -destinationFile $convertChangelogFile -fileDescription "Changelog file"