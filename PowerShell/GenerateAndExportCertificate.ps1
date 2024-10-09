# --- One tool to upload/manipulate files on Sharepoint from remote is the CLI for Microsoft 365: https://pnp.github.io/cli-microsoft365/
# --- To properly use it, however, a login method is required. The following script explain how to generate the .pfx and .cer files needed to achieve that.
# --- The first is passed as argument to the login command, the 2nd needs to be uploaded on the Azure portal, under the App registration section.

param (
    [string]$Subject = "SubjectName",                      # The subject name of the certificate
    [int]$DurationInYears = 1,                             # Duration in years for the certificate validity
    [string]$PfxExportPath = "YourExportPath.pfx",         # The export path for the PFX file
    [string]$CerExportPath = "YourExportPath.cer",         # The export path for the CER file
    [string]$Password,                                     # Password for the PFX file
    [switch]$Verbose                                       # Enable verbose output
)

# --- Prompt for Password if not provided ---
if (-not $Password) {
    $Password = Read-Host -Prompt "Enter a strong password for the PFX file" -AsSecureString
}

# --- Generate a self-signed certificate ---
try {
    Write-Output "Generating self-signed certificate..."
    $cert = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -Subject $Subject -KeyLength 2048 -NotAfter (Get-Date).AddYears($DurationInYears)

    # Get the thumbprint of the certificate
    $thumbprint = $cert.Thumbprint
    Write-Output "Generated Certificate Thumbprint: $thumbprint"
}
catch {
    Write-Error "Failed to generate the certificate: $_"
    exit 1
}

# --- Export as PFX (with private key) ---
try {
    Write-Output "Exporting certificate as PFX..."
    Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$thumbprint" -FilePath $PfxExportPath -Password $Password -Force
    Write-Output "PFX Certificate exported to: $PfxExportPath"
}
catch {
    Write-Error "Failed to export PFX: $_"
    exit 1
}

# --- Export as CER (public key only) ---
try {
    Write-Output "Exporting certificate as CER (public key only)..."
    Export-Certificate -Cert "Cert:\CurrentUser\My\$thumbprint" -FilePath $CerExportPath -Force
    Write-Output "CER Certificate exported to: $CerExportPath"
}
catch {
    Write-Error "Failed to export CER: $_"
    exit 1
}

Write-Output "Script completed successfully."

Read-Host -Prompt "Press Enter to exit"

