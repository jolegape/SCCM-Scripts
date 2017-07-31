<#
.SYNOPSIS
    Creates user collections in SCCM from a base Active Directory OU.
.NOTES
    FileName:       User_OU.ps1
    Author:         Gavin Willett
    Prerequisite:   This script requires that the powershell configuration module be loaded. 
                    The easiest way to ensure this is to connect via windows powershell from
                    the Configuration Manager Console. If run from a regular powershell session
                    the Configuration Manager module will be loaded. This requires the Admin Console
                    to be installed on the machine.
    Last Updated:   01/08/2017
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

# Set Refresh Schedule Parameters
$ScheduleDate = Get-Date -Format "dd/MM/yy HH:MM tt"
$RefreshSchedule = New-CMSchedule -Start $ScheduleDate -RecurInterval Days -RecurCount 1

# Folder location for User Collections
$StaffOUFolder = "${SiteCode}:\UserCollection\SMC\SMC Staff OU"
$StudentOUFolder = "${SiteCode}:\UserCollection\SMC\SMC Student OU"

# OU's to search
$StaffOUList = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Staff Users,OU=SMC,OU=Automated Objects,DC=example,DC=school,DC=edu,DC=au" -Properties CanonicalName | Sort-Object CanonicalName
$StudentOUList = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Student Users,OU=SMC,OU=Automated Objects,DC=example,DC=school,DC=edu,DC=au" -Properties CanonicalName | Sort-Object CanonicalName

# Check if folder location for staff user collection exists, and create if needed.
if (!(Test-Path $StaffOUFolder)) {
    md $StaffOUFolder
}

# Create collection for each Staff OU in the list
# .Substring(40) removes the first 40 characters from the CanonicalName of an OU.
# eg: example.school.edu.au/Automated Objects/SMC/Staff Users
# would become SMC/Staff Users
# Change or remove the substring parameter as required.
foreach ($StaffOU in $StaffOUList.CanonicalName.Substring(40)) {
    if (!(Get-CMDeviceCollection -Name "$($StaffOU)")) {
        New-CMDeviceCollection -Name "$($StaffOU)" -LimitingCollectionName "All Users" -RefreshType Periodic -RefreshSchedule $RefreshSchedule | Move-CMObject -FolderPath $StaffOUFolder
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName "$($StaffOU)" -QueryExpression "select * from SMS_R_User where SMS_R_User.UserOUName like ""%$($StaffOU)%""" -RuleName "OU Members - $($StaffOU)"
    }
}

# Check if folder location for student user collection exists, and create if needed.
if (!(Test-Path $StudentOUFolder)) {
    md $StudentOUFolder
}

# Create collection for each Staff OU in the list
# .Substring(40) removes the first 40 characters from the CanonicalName of an OU.
# eg: example.school.edu.au/Automated Objects/SMC/Student Users
# would become SMC/Student Users
# Change or remove the substring parameter as required.
foreach ($StudentOU in $StudentOUList.CanonicalName.Substring(40)) {
    if (!(Get-CMDeviceCollection -Name "$($StudentOU)")) {
        New-CMDeviceCollection -Name "$($StudentOU)" -LimitingCollectionName "All Users" -RefreshType Periodic -RefreshSchedule $RefreshSchedule | Move-CMObject -FolderPath $StudentOUFolder
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName "$($StudentOU)" -QueryExpression "select * from SMS_R_User where SMS_R_User.UserOUName like ""%$($StudentOU)%""" -RuleName "OU Members - $($StudentOU)"
    }
}