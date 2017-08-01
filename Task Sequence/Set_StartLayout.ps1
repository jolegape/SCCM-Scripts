<#
.SYNOPSIS
    Copies the Start Menu & Taskbar layout and imports it to the default profile
.NOTES
    FileName:       Set_StartLayout.ps1
    Author:         Gavin Willett
    Prerequisite:   This script runs during an OSD Task Sequence after it has booted into the OS.
                    It will not work if run during the WinPE phase.
    Last Updated:   01/08/2017
.LINK
    Scripts hosted at:
    https://github.com/jolegape/SCCM-Scripts
#>

# Copy Layout to local drive
Write-Output -InputObject "Copying CMTrace.exe to Windows Dir"
Copy-Item "\\SMCFS001.example.school.edu.au\SCCMLibrary\SCCMScripts\OSDFiles\StartMenuLayout.xml" -destination "$($env:SystemRoot)\System32"

# Import Layout to default profile
Write-Output -InputObject "Importing Start Menu and Taskbar layout"
Import-Startlayout -LayoutPath "$($env:SystemRoot)\System32\StartMenuLayout.xml" -MountPath $env:SystemDrive\