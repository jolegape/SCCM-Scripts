<#
.SYNOPSIS
    Creates device collections in SCCM from a list of computer models.
.NOTES
    FileName:       Hardware_Models.ps1
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
    Write-Host "Importing ConfigMgr module..."
    Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
}

# Get Site Code
$SiteCode = (Get-PSDrive | where {$_.Provider.Name -eq "CMSite"}).Name

# Set Refresh Schedule Parameters
$ScheduleDate = Get-Date -Format "dd/MM/yy HH:MM tt"
$RefreshSchedule = New-CMSchedule -Start $ScheduleDate -RecurInterval Days -RecurCount 1

# Folder location for Hardware Collections
$ModelFolder = "${SiteCode}:\DeviceCollection\SMC\SMC Computer Models"

# Models to add
$ModelList = @{
    #CollectionName                             #SearchQuery
    "Apple iMac (iMac12,2)"                 =   "imac12,2";
    "Apple iMac (iMac13,2)"                 =   "iMac13,2";
    "Apple iMac (iMac14,2)"                 =   "iMac14,2";
    "Apple MacBook Pro (MacBookPro8,2)"     =   "MacBookPro8,2";
    "Apple Macbook Pro (MacBookPro13,1)"    =   "MacBookPro13,1";
    "Dell Latitude E5440"                   =   "Latitude E5440";
    "Dell Latitude E5450"                   =   "Latitude E5450";
    "Dell Latitude 3160"                    =   "Latitude 3160";
    "Dell Latitude 3340"                    =   "Latitude 3340";
    "Dell Latitude 3350"                    =   "Latitude 3350";
    "Dell Optiplex 755"                     =   "Optiplex 755";
    "Dell Optiplex 760"                     =   "Optiplex 760";
    "Dell Optiplex 780"                     =   "Optiplex 780";
    "Dell PowerEdge R420"                   =   "PowerEdge R420";
    "Dell PowerEdge R710"                   =   "PowerEdge R710";
    "Dell PowerEdge R720"                   =   "PowerEdge R720";
    "HP 210 G1"                             =   "HP 210";
    "HP Compaq Elite 8300 SFF"              =   "Elite 8300 SFF";
    "HP EliteBook 820 G1"                   =   "820 G1";
    "HP EliteDesk 800 G1 SFF"               =   "800G1 SFF";
    "HP ProBook 6470b"                      =   "6470b";
    "HP ProBook 650 G1"                     =   "650 G1";
    "HP ProBook 6550b"                      =   "6550b"
    "HP Z1 Workstation"                     =   "Z1";
    "Microsoft Surface Pro 3"               =   "Surface Pro 3";
    "Virtual Machines"                      =   "Virtual Machine";
}

# Check if folder location for hardware models exists, and create if needed.
if (!(Test-Path $ModelFolder)) {
    md $ModelFolder
}

# Create hardware collection for each model in the list
foreach ($Model in $ModelList.GetEnumerator() | Sort-Object Name) {
    if (!(Get-CMDeviceCollection -Name "SMC - $($Model.Key)")) {
        New-CMDeviceCollection -Name "SMC - $($Model.Key)" -LimitingCollectionName "SMC All Systems" -RefreshType Periodic -RefreshSchedule $RefreshSchedule | Move-CMObject -FolderPath $ModelFolder
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName "SMC $($Model.Key)" -QueryExpression "select * from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceID where SMS_G_System_COMPUTER_SYSTEM.Model like ""%$($Model.Value)%""" -RuleName "SMC Hardware Model - $($Model.Key)"
    }
}