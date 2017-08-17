<#
.SYNOPSIS
    Creates device collections in SCCM from a base Active Directory OU.
.NOTES
    FileName:       AD_OU.ps1
    Author:         Gavin Willett
    Prerequisite:   This script requires that the powershell configuration module be loaded. 
                    The easiest way to ensure this is to connect via windows powershell from
                    the Configuration Manager Console. If run from a regular powershell session
                    the Configuration Manager module will be loaded. This requires the Admin Console
                    to be installed on the machine.
    Last Updated:   31/07/2017
.LINK
    Scripts hosted at:
    https://github.com/jolegape/SCCM-Scripts
#>

# Load Configuration Manager module if it is not already
if (!(Get-Module "ConfigurationManager")) {
    if ([Environment]::Is64BitOperatingSystem) {
        Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
    } else {
        Import-Module "C:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
    }
}

# Get Site Code
$SiteCode = (Get-PSDrive | where {$_.Provider.Name -eq "CMSite"}).Name

#Change to Configuration Manager drive
Set-Location -Path "$($SiteCode):"

# Set Refresh Schedule Parameters
$ScheduleDate = Get-Date -Format "dd/MM/yy HH:MM tt"
$RefreshSchedule = New-CMSchedule -Start $ScheduleDate -RecurInterval Days -RecurCount 1

# Folder location for Hardware Collections
$OUFolder = "${SiteCode}:\DeviceCollection\SMC\SMC Computer OU"

# OU to search
$OUList = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Windows Computers,OU=SMC,OU=Resources,DC=example,DC=school,DC=edu,DC=au" -Properties CanonicalName | Sort-Object CanonicalName

# Check if folder location for OU collection exists, and create if needed.
if (!(Test-Path $OUFolder)) {
    md $OUFolder
}

# Create collection for each OU in the list
# .Substring(32) removes the first 32 characters from the CanonicalName of an OU.
# eg: example.school.edu.au/Resources/SMC/Windows Computers/Testing
# would become SMC/Windows Computers/Testing
# Change or remove the substring parameter as required.
foreach ($OU in $OUList.CanonicalName.Substring(32)) {
    if (!(Get-CMDeviceCollection -Name "$($OU)")) {
        New-CMDeviceCollection -Name "$($OU)" -LimitingCollectionName "All Systems" -RefreshType Periodic -RefreshSchedule $RefreshSchedule | Move-CMObject -FolderPath $OUFolder
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName "$($OU)" -QueryExpression "select * from SMS_R_System where SMS_R_System.SystemOUName like ""%$($OU)%""" -RuleName "OU Members - $($OU)"
    }
}