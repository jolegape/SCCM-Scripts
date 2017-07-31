<#
.SYNOPSIS
    Creates user collections in SCCM from Active Directory groups.
.NOTES
    FileName:       User_Groups.ps1
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
$StaffGroupFolder = "${SiteCode}:\UserCollection\SMC\SMC Staff Groups"
$StudentGroupFolder = "${SiteCode}:\UserCollection\SMC\SMC Student Groups"

# OU to search
$StaffGroupList = Get-ADGroup -Filter * -SearchBase "OU=Staff Groups,OU=SMC,OU=Automated Objects,DC=example,DC=school,DC=edu,DC=au" | Sort-Object Name
$StudentGroupList = Get-ADGroup -Filter * -SearchBase "OU=Student Groups,OU=SMC,OU=Automated Objects,DC=example,DC=school,DC=edu,DC=au" | Sort-Object Name

# Check if folder location for staff user collection exists, and create if needed.
if (!(Test-Path $StaffFolder)) {
    md $StaffFolder
}

# Create collection for each group in the staff groups OU
foreach ($StaffGroup in $StaffGroupList.Name) {
    if (!(Get-CMUserCollection -Name "$($StaffGroup)")) {
        New-CMUserCollection -Name "$($StaffGroup)" -LimitingCollectionName "All Users" -RefreshType Periodic -RefreshSchedule $RefreshSchedule | Move-CMObject -FolderPath $StaffFolder
        Add-CMUserCollectionQueryMembershipRule -CollectionName "$($StaffGroup)" -QueryExpression "select * from SMS_R_USER where SMS_R_User.UserGroupName like ""%$($StaffGroup)%""" -RuleName "Group Members - $($StaffGroup)"
    }
}

# Check if folder location for student user collection exists, and create if needed.
if (!(Test-Path $StudentFolder)) {
    md $StudentFolder
}

# Create collection for each group in the student groups OU
foreach ($StudentGroup in $StudentGroupList.Name) {
    if (!(Get-CMUserCollection -Name "$($StudentGroup)")) {
        New-CMUserCollection -Name "$($StudentGroup)" -LimitingCollectionName "All Users" -RefreshType Periodic -RefreshSchedule $RefreshSchedule | Move-CMObject -FolderPath $StudentFolder
        Add-CMUserCollectionQueryMembershipRule -CollectionName "$($StudentGroup)" -QueryExpression "select * from SMS_R_USER where SMS_R_User.UserGroupName like ""%$($StudentGroup)%""" -RuleName "Group Members - $($StudentGroup)"
    }
}