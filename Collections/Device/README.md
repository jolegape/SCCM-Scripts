# SCCM Device Collections
------------
A collection of powershell scripts I am currently using in my workplace.

All of these scripts require the ConfigurationManager powershell module to be loaded. The easiest way is to use the ***Connect via Windows Powershell*** option from the SCCM Admin Console menu. The scripts will automatically load the module if it is not already loaded. This requires the Admin Console to be installed on the system you are running the scripts on.

My workplace uses a shared SCCM instance for the whole district, rather than individually managed instances. For this reason my collections are created in a **SMC** subfolder and use that as a prefix to indicate my workplace and prevent duplicate naming issues with other sites. If you only have one instance / are not sharing with other sites, you can remove the subfolder and prefix from the scripts if you wish.

The following changes will need to be made for all scripts to suit your environment:
- Model / Operating System / AD OU Lists
- Refresh Schedule

As with any code on the internet, don't blindly copy and paste / run what you download without reading it first. These scripts work for me, but may not for you. I am not responsible for any side effects of using these scripts, but am more than happy to help where I can.

The following scripts are provided:
1. Hardware Models ([Hardware_Model.ps1](https://github.com/jolegape/SCCM-Scripts/blob/master/Collections/Device/Hardware_Model.ps1 "Hardware_Model.ps1"))
2. Operating Systems ([Operating_System.ps1](https://github.com/jolegape/SCCM-Scripts/blob/master/Collections/Device/Operating_System.ps1 "Operating_System.ps1"))
3. Active Directory OU ([AD_OU.ps1](https://github.com/jolegape/SCCM-Scripts/blob/master/Collections/Device/AD_OU.ps1 "AD_OU.ps1"))