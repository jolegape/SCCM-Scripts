<#
.SYNOPSIS
    Creates device collections in SCCM from a list of operating systems.
.NOTES
    FileName:       Operating_System.ps1
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

# Set Refresh Schedule Parameters
$ScheduleDate = Get-Date -Format "dd/MM/yy HH:MM tt"
$RefreshSchedule = New-CMSchedule -Start $ScheduleDate -RecurInterval Days -RecurCount 1

# Folder location for Hardware Collections
$OSFolder = "${SiteCode}:\DeviceCollection\SMC\SMC Operating Systems"

# operating Systems
$OSList = @{
    #CollectionName                     #SearchQuery
    "macOS 10.8 (Mountain Lion)"    =   "OS X 10.8";
    "macOS 10.9 (Mavericks)"        =   "OS X 10.9";
    "macOS 10.10 (Yosemite)"        =   "OS X 10.10";
    "macOS 10.11 (El Capitan)"      =   "OS X 10.11";
    "macOS 10.12 (Sierra)"          =   "OS X 10.12";
    "Windows 7"                     =   "Workstation 6.1";
    "Windows 8"                     =   "Workstation 6.2";
    "Windows 8.1"                   =   "Workstation 6.3";
    "Windows 10 (v1507)"            =   "10.0.10240";
    "Windows 10 (v1511)"            =   "10.0.10586";
    "Windows 10 (v1607)"            =   "10.0.14393";
    "Windows 10 (v1703)"            =   "10.0.15063";
    "Windows Server 2008"           =   "Server 6.0";
    "Windows Server 2008 R2"        =   "Server 6.1";
    "Windows Server 2012"           =   "Server 6.2";
    "Windows Server 2012 R2"        =   "Server 6.3";
    "Windows Server 2016"           =   "Server 10";
}

# Check if folder location for operating systems exists, and create if needed.
if (!(Test-Path $OSFolder)) {
    md $OSFolder
}

# Create collection for each OS in the list
foreach ($OS in $OSList.GetEnumerator() | Sort-Object Name) {
    if (!(Get-CMDeviceCollection -Name "SMC - $($OS.Key)")) {
        New-CMDeviceCollection -Name "SMC - $($OS.Key)" -LimitingCollectionName "SMC All Systems" -RefreshType Periodic -RefreshSchedule $RefreshSchedule | Move-CMObject -FolderPath $OSFolder

        # If OS.Key is like Windows 10 use the following SearchQuery, else use the default SearchQuery
        if ($($OS.Key) -like "Windows 10*") {
            $SearchQuery = "select * from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_OPERATING_SYSTEM.Name like ""%Windows 10%"" AND SMS_G_System_OPERATING_SYSTEM.Version like ""%$(%OS.Value)%"""
        } else {
            $SearchQuery = "select * from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like ""%$($OS.Value)%"""
        }
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName "SMC - $($OS.Key)" -QueryExpression $SearchQuery -RuleName "OS Version - $($OS.Key)"
    }
}