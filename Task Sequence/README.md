# SCCM Task Sequence Scripts
------------
A collection of powershell and Visual Basic scripts I am currently using in my workplace. I used to create a base image with previous versions of Windows 7 and 8.1. Since Windows 10 is a constant rolling release, and we re-image computers fairly regularly, I found it easier to make changes to the image on the fly as it is deployed. This means I only need to add the new install.wim to SCCM each time a new version of Windows 10 is released and I am up and running again.

All of these scripts can be run during a task sequence. They will not run during the WinPE stage. The task sequence must have restarted into the OS to run these scripts.

The following changes will need to be made to suit your environment:
- File paths in any scripts
- Preferred computer description format
- Add/remove any apps that you want removed from the installation of Windows.

As with any code on the internet, don't blindly copy and paste / run what you download without reading it first. These scripts work for me, but may not for you. I am not responsible for any side effects of using these scripts, but am more than happy to help where I can.

The following scripts are provided:
1. Set computer description in Active Directory and locally ([Set_ComputerDescription.vbs](https://github.com/jolegape/SCCM-Scripts/blob/master/Task%20Sequence/Set_ComputerDescription.vbs "Set_ComputerDescription.vbs"))
2. Set start menu layout  ([Set_StartLayout.ps1](https://github.com/jolegape/SCCM-Scripts/blob/master/Task%20Sequence/Set_StartLayout.ps1 "Set_StartLayout.ps1"))
3. Windows 10 modifications  ([Windows10_Modifications.ps1](https://github.com/jolegape/SCCM-Scripts/blob/master/Task%20Sequence/Windows10_Modifications.ps1 "Windows10_Modifications.ps1"))
