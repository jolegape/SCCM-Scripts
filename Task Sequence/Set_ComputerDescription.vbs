' -----------------------------------------------------------
' Populates the computer description field in AD and locally
' with the Model, Serial Number and imaged date.
' 
' 
' 
' File:			Set_ADComputerDescription.vbs
' Usage:		cscript Set_ADComputerDescription.vbs
' Author:		Gavin Willett
' Last Updated:	01/08/2017
' 
' Script hosted at https://github.com/jolegape/SCCM-Scripts
' -----------------------------------------------------------

Set WSNetwork = WScript.CreateObject("WScript.Network")
Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
Set objADSysInfo = CreateObject("ADSystemInfo")

' Get Manufacturer, Model and SN
for each objItem in objWMI.ExecQuery("select * from Win32_ComputerSystemProduct")
	manufacturer = objItem.Vendor
	model = objItem.Name
	sn = objItem.IdentifyingNumber
Next

' Create description string in the following format of Manufacturer Model (SN) | Imaged on: dd/mm/yyyy
' eg Dell Latitude E5450 (abcd123) | Imaged on: 01/08/2017
strComputerDescription = Trim(manufacturer) & " " & Trim(model) & " (" & Trim(sn) & ") | Imaged on: " & formattedDate(date)

' Get Computer Distinguished Name
ComputerDN = "LDAP://" & objADSysInfo.ComputerName

' Set Description in Active Directory
Set objADComputer = GetObject(ComputerDN)
objADComputer.Put "Description", strComputerDescription
objADComputer.SetInfo

' Set Description locally
for each objItem in objWMI.ExecQuery("select * from Win32_OperatingSystem")
	objItem.Description = strComputerDescription
	objItem.Put_
Next


' Functions used above.
' Add leading 0 to number if only a single digit
Function FormatNumber(number)
	If(Len(number)=1) Then
		FormatNumber="0"&number
	Else
		FormatNumber=number
	End If
End Function

' Get Date and format into DD/MM/YYYY
' By default VBS will format to d/m/yyyy
Function formattedDate(date)
	dd = FormatNumber(Day(date))
	mm = FormatNumber(Month(date))
	yy = Year(date)
	formattedDate = dd & "/" & mm & "/" & yy
End Function