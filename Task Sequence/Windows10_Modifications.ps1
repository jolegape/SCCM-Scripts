<#
.SYNOPSIS
    Adds and removes various Windows 10 features to get it to an acceptable state for educational use.
.NOTES
    FileName:       Windows10_Modifications.ps1
    Author:         Gavin Willett
    Prerequisite:   This script runs during an OSD Task Sequence after it has booted into the OS.
                    It will not work if run during the WinPE phase.
    Last Updated:   18/10/2017
.LINK
    Scripts hosted at:
    https://github.com/jolegape/SCCM-Scripts
#>

# Try connect to SMS Log Path, fallback to TEMP folder if unable to connect
try {
    $tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
    $logPath = $tsenv.Value("_SMSTSLogPath")
}
catch {
    $logPath = $env:TEMP
}

# Start Logging
Start-Transcript "$($logPath)\$($myInvocation.MyCommand).log"

# Built in Windows 10 apps to be removed
$apps_list = @(
    "Microsoft.3DBuilder"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    #"Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    #"Microsoft.MSPaint"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    #"Microsoft.Windows.Photos"
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

# Remove Windows Capabilities
$capabilities_list = @(
    "App.Support.QuickAssist~~~~0.0.1.0"
    "App.Support.ContactSupport~~~~0.0.1.0"
)

foreach ($capability in $capabilities_list) {

    # Attempt to remove Windows Capability
    try {
        Write-Output -InputObject "Removing Windows Capability: $($capability)"
        Remove-WindowsCapability -Online -Name $capability
    } 
    catch {
        break
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
# Searches the base_path for a folder matching the ReleaseID of Windows (1607, 1703, 1709, etc), and then for the matching processor_architecture (amd64, x86)
# Files will need to be copied from Source ISO\Sources\sxs folder to the appropriate release ID and architecture folder.
try {
    $base_path = "\\SMCFS001.cairns.catholic.edu.au\SCCMLibrary\SoftwareInstallPackages\Microsoft .Net Framework"
    $os_vers = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop).ReleaseID
    Write-Output -InputObject "Installing NetFX3 Package"
    Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -LimitAccess -Source "$($base_path)\$($os_vers)\$($env:processor_architecture)" -NoRestart
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
    Write-Output -InputObject "Copying SMC_Win10_File_Associations.xml to System32 Dir"
    Copy-Item "\\SMCFS001.cairns.catholic.edu.au\SCCMLibrary\SCCMScripts\OSDFiles\SMC_Win10_File_Associations.xml" -destination "$($env:SystemRoot)\System32"
    Write-Output -InputObject "Copying StartMenuLayout.xml to System32 Dir"
    Copy-Item "\\SMCFS001.cairns.catholic.edu.au\SCCMLibrary\SCCMScripts\OSDFiles\StartMenuLayout.xml" -destination "$($env:SystemRoot)\System32"
}
catch {
    Break
}

# Set Default File Associations
try {
    Write-Output -InputObject "Importing Default File Associations"
    dism /online /Import-DefaultAppAssociations:"$($env:SystemRoot)\System32\SMC_Win10_1703_File_Associations.xml"
}
catch {
    Break
}

# Set Default Start Menu and Taskbar Layout
try {
    Write-Output -InputObject "Importing startmenu Layout"
    Import-StartLayout -LayoutPath "$($env:SystemRoot)\System32\StartMenuLayout.xml" -MountPath "$($env:SystemDrive)\"
}
catch {
    Break
}

# Stop Logging
Stop-Transcript