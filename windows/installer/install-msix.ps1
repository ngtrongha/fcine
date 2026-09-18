param(
    [Parameter(Mandatory = $true)]
    [string]$MsixPath,
    [string]$MinVersion = '0.0.0.0'
)

$ErrorActionPreference = 'Stop'
$name = 'com.fcine.fcine'

$pkg = Get-AppxPackage -Name $name
if ($pkg -and [version]$pkg.Version -ge [version]$MinVersion) {
    Write-Host "F-Cine $($pkg.Version) already installed - skipping MSIX install"
    exit 0
}

Add-AppxPackage -Path $MsixPath
Write-Host "F-Cine MSIX installed successfully"
