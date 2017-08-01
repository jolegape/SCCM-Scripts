<#
.SYNOPSIS
    Adds and removes various Windows 10 features to get it to an acceptable state for educational use.
.NOTES
    FileName:       Windows10_Modifications.ps1
    Author:         Gavin Willett
    Prerequisite:   This script runs during an OSD Task Sequence after it has booted into the OS.
                    It will not work if run during the WinPE phase.
    Last Updated:   01/08/2017
.LINK
    Scripts hosted at:
    https://github.com/jolegape/SCCM-Scripts
#>

# Built in Windows 10 apps to be removed
$apps_list = @(
    "Microsoft.3DBuilder"
    "Microsoft.BingWeather"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Micrsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MSPaint"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Windows.Photos"
    "Microsoft.SkypeApp"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
)

foreach ($app in $apps_list) {
    # Gather Package Names
    $AppPackageFullName = Get-AppxPackage -name *$app* | Select-Object -ExpandProperty PackageFullName
    $AppProvisioningPackageName = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Select-Object -ExpandProperty PackageName

    # Attempt to remove AppxPackage
    try {
        Write-Output -InputObject "Removing AppxPackage: $($AppPackageFullName)"
        Remove-AppxPackage -Package $AppPackageFullName
    }
    catch [System.Exception]{
        Write-Warning -Message $_.Exception.Message
    }

    # Attempt to remove AppxProvisioningPackage
    try {
        Write-Output -InputObject "Removing AppxProvisioningPackage: $($AppProvisioningPackageName)"
        Remove-AppxProvisionedPackage -PackageName $AppProvisioningPackageName -Online 
    }
    catch [System.Exception]{
        Write-Warning -Message $_.Exception.Message
    }
}

# Disable Internet Explorer
try {
    Write-Output -InputObject "Disabling Internet Explorer"
    Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-$env:processor_architecture -NoRestart
}
catch {
    break
}

# Disable SMB1 Protocol
try {
    Write-Output -InputObject "Disabling SMB1 Protocol"
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -Remove -NoRestart
}
catch {
    break
}

# Add NetFX3 package
# Files in the 1703 folder are specific to Windows 10 Creators Update.
# This path will need to be changed for future releases of Windows 10.
try {
    Write-Output -InputObject "Installing NetFX3 Package"
    Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -LimitAccess -Source "\\SMCFS001.example.school.edu.au\SCCMLibrary\SoftwareInstallPackages\Microsoft .Net Framework 3\1703" -NoRestart
}
catch {
    Break
}

# Copy Required Files
try {
    Write-Output -InputObject "Copying CMTrace.exe to Windows Dir"
    Copy-Item "\\SMCFS001.example.school.edu.au\SCCMLibrary\SoftwareInstallPackages\Tools\CMTrace.exe" -destination $($env:SystemRoot)
    Write-Output -InputObject "Copying ProcMon.exe to Windows Dir"
    Copy-Item "\\SMCFS001.example.school.edu.au\SCCMLibrary\SoftwareInstallPackages\Sys Internals\Procmon.exe" -destination $($env:SystemRoot)
    Write-Output -InputObject "Copying ProcExp.exe to Windows Dir"
    Copy-Item "\\SMCFS001.example.school.edu.au\SCCMLibrary\SoftwareInstallPackages\Sys Internals\ProcExp.exe" -destination $($env:SystemRoot)
    Write-Output -InputObject "Copying BgInfo.exe to Windows Dir"
    Copy-Item "\\SMCFS001.example.school.edu.au\SCCMLibrary\SoftwareInstallPackages\Tools\Bginfo.exe" -destination $($env:SystemRoot)
    Write-Output -InputObject "Copying SMC Launcher shortcut to default start menu"
    Copy-Item "\\SMCFS001.example.school.edu.au\SCCMLibrary\SCCMScripts\OSDFiles\Launcher.url" -destination "$($env:ProgramData)\Microsoft\Windows\Start Menu\Programs"
}
catch {
    Break
}