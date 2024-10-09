# --- Script to limit the number of builds in a target sharepoint folder by deleting the oldest ones, requires CLI for Microsodft 365 ---
# --- Used to keep in check the folder size ---   

function Remove-FolderRecursively($siteUrl, $folderPath) {
    try {
        # --- List all files in the folder --- 
        $files = m365 spo file list --webUrl $siteUrl --folderUrl $folderPath --output json | ConvertFrom-Json
        foreach ($file in $files) {
            $fileUrl = $file.ServerRelativeUrl
            Write-Host "Deleting file: $fileUrl"
            m365 spo file remove --webUrl $siteUrl --url $fileUrl --confirm -Force
        }

        # --- List all subfolders in the folder --- 
        $subfolders = m365 spo folder list --webUrl $siteUrl --parentFolderUrl $folderPath --output json | ConvertFrom-Json
        foreach ($subfolder in $subfolders) {
            $subfolderPath = $subfolder.ServerRelativeUrl
            Remove-FolderRecursively $siteUrl $subfolderPath
        }
    }
    catch {
        Write-Error "Error while deleting contents of folder: $folderPath. $_"
    }
}

Write-host 'ensure logged in'
$m365Status = m365 status --output text
if ($m365Status -eq "Logged Out") {
    try {
        Write-Host "Logging in to M365..."
        $certPath = "PfxFileDirectory/PfxCertificate.pfx"
        $thumbprint = "YourThumbprint"
        $password = YourPassword

        # --- Assuming this script is running in a CI/CD environment, the $thumbprint and the $password variables MUST be passed in as environment variables for security purposes ---
        # --- For more info regarding the .pfx certificate, check the GenerateAndExportCertificate.ps1 file
        m365 login --authType certificate --certificateFile $certPath --thumbprint $thumbprint --password $password
        Write-Host "Login successful."
    }
    catch {
        Write-Error "Login failed: $_"
        exit 1
    }
}

$folderTarget = 'SharepointFolderAddress'
$siteUrl = 'MSTeamsTeamAddress'
$buildsToKeep = 10
  
Write-host 'log in successful, start deleting extra builds'

m365 spo set --url $siteUrl

# --- Get the list of builds ---
try {
    Write-Host "Retrieving folder information..."
    $foldersInfo = m365 spo folder list --webUrl $siteUrl --parentFolderUrl $folderTarget --output json
    $formattedFolderInfo = $foldersInfo | ConvertFrom-Json
    Write-Host "Folders retrieved successfully."
}
catch {
    Write-Error "Failed to retrieve folder information: $_"
    exit 1
}

# --- Sort builds by creation time and keep the latest X based on variable ---
$sortedBuilds = $formattedFolderInfo | Sort-Object { [DateTime]$_.timeCreated } -Descending
$buildsToDelete = $sortedBuilds | Select-Object -Skip $buildsToKeep

if ($buildsToDelete.Count -eq 0) {
    Write-Host "No builds to delete."
    exit 0
}

# --- Recursively delete each folder --- 
foreach ($folder in $buildsToDelete) {
    $folderPath = $folder.ServerRelativeUrl
    Write-Host "Recursively removing folder contents for: $folderPath"
    Remove-FolderRecursively $siteUrl $folderPath
}

# --- Remove the parent folders themselves --- 
foreach ($folder in $buildsToDelete) {
    $folderPath = $folder.ServerRelativeUrl
    Write-Host "Deleting folder: $folderPath"
    try {
        m365 spo folder remove --webUrl $siteUrl --url $folderPath --confirm -Force
        Write-Host "Folder $folderPath removed."
    }
    catch {
        Write-Error "Failed to delete folder: $folderPath. $_"
    }
}

Write-host 'builds in excess deleted'