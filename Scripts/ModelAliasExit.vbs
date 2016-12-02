Function UserExit(sType, sWhen, sDetail, bSkip)
	oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs started: " & sType & " " & sWhen & " " & sDetail, LogTypeInfo
	UserExit = Success
End Function

Function SetModelAlias()
	oLogging.CreateEntry "------------ Initialization USEREXIT:ModelAliasExit.vbs|SetModelAlias -------------", LogTypeInfo
	sMake = oEnvironment.Item("Make")
	sModel = oEnvironment.Item("Model")
	SetModelAlias = ""
	sCSPVersion = ""
	sCSPName = ""
	sBIOSVersion = ""

	Set colComputerSystemProduct = objWMI.ExecQuery("SELECT * FROM Win32_ComputerSystemProduct")
	If Err then
		oLogging.CreateEntry "Error querying Win32_ComputerSystemProduct: " & Err.Description & " (" & Err.Number & ")", LogTypeError
	Else
		For Each objComputerSystemProduct in colComputerSystemProduct
			' Version
			If not IsNull(objComputerSystemProduct.Version) then
				sCSPVersion = Trim(objComputerSystemProduct.Version)
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Win32_ComputerSystemProduct Version: " & sCSPVersion, LogTypeInfo
			End If

			' Name
			If not IsNull(objComputerSystemProduct.Name) then
				sCSPName = Trim(objComputerSystemProduct.Name)
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Win32_ComputerSystemProduct Name: " & sCSPName, LogTypeInfo
			End If
		Next
	End if

	Set colBIOS = objWMI.ExecQuery("SELECT * FROM Win32_BIOS")
	If Err then
		oLogging.CreateEntry "Error querying Win32_BIOS: " & Err.Description & " (" & Err.Number & ")", LogTypeError
	Else
		For Each objBIOS in colBIOS
			If not IsNull(objBIOS.Version) then
				sBIOSVersion = Trim(objBIOS.Version)
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Win32_BIOS Version: " & sBIOSVersion, LogTypeInfo
			End If
		Next
	End if

	' Sometimes we does not have OEM systems...
	If sMake = "System manufacturer" then
		Set colBaseBoard_a = objWMI.ExecQuery("SELECT * FROM Win32_Baseboard")
		For Each objBaseBoard in colBaseBoard_a
			If not IsNull(objBaseBoard.Product) then
				sMake = Trim(objBaseBoard.Manufacturer)
			End If
		Next
	End if

	Select Case sMake
		Case "ASUSTeK Computer INC."
			sMake = "ASUS"
	
			Set colBaseBoard_b = objWMI.ExecQuery("SELECT * FROM Win32_Baseboard")
			If Err then
				oLogging.CreateEntry "Error querying Win32_Win32_Baseboard: " & Err.Description & " (" & Err.Number & ")", LogTypeError
			Else
				For Each objBaseBoard in colBaseBoard_b
					If not IsNull(objBaseBoard.Product) then
						SetModelAlias = Trim(objBaseBoard.Product)
					End If
				Next
			End if

			oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
		Case "Dell Computer Corporation", "Dell Inc.", "Dell Computer Corp."
			SetModelAlias = sModel
		Case "TOSHIBA"
			If not sCSPName = "" then 
				SetModelAlias = sCSPName
			Else
				SetModelAlias = sModel
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
			End If
		Case "Hewlett-Packard"
			Select Case sModel
				Case "HP Compaq nw8240 (PY442EA#AK8)"
					SetModelAlias = "HP Compaq nw8240"
				Case Else
					SetModelAlias = sModel 
					oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
			End Select
		Case "HP"
			SetModelAlias = sModel
		Case "IBM"
			Select Case sModel
				Case "---[HS22]---"
					SetModelAlias = "IBMHS22"
				Case Else
					SetModelAlias = sModel 
					oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
			End Select
		Case "LENOVO"
			If IsNumeric(Left(sModel,4)) and not sCPVersion = "" then
				SetModelAlias = sCSPVersion
			Else
				SetModelAlias = sModel
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
			End IF
		Case "LENOVO"
			If IsNumeric(Left(sModel,4)) and not sCPVersion = "" then
				SetModelAlias = sCSPVersion
			Else
				SetModelAlias = sModel
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
			End IF
		Case "Matsushita Electric Industrial Co.,Ltd."
			If Left(sModel,2) = "CF" Then 
				SetModelAlias = Left(sModel,5)
			Else
				SetModelAlias = sModel 
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
			End If
		Case "Microsoft Corporation"
			Select Case sBIOSVersion
				Case "VRTUAL - 1000831"
					SetModelAlias = "Hyper-V2008BetaorRC0"
				Case "VRTUAL - 5000805", "BIOS Date: 05/05/08 20:35:56  Ver: 08.00.02"
					SetModelAlias = "Hyper-V2008RTM"
				Case "VRTUAL - 3000919" 
					SetModelAlias = "Hyper-V2008R2"
				Case "VRTUAL - 9001114" 
					SetModelAlias = "Hyper-V2012BETA"
				Case "A M I  - 2000622"
					SetModelAlias = "VS2005R2SP1orVPC2007"
				Case "A M I  - 9000520"
					SetModelAlias = "VS2005R2"
				Case "A M I  - 9000816", "A M I  - 6000901"
					SetModelAlias = "WindowsVirtualPC"
				Case "A M I  - 8000314"
					SetModelAlias = "VS2005orVPC2004"
				Case Else
					SetModelAlias = sModel 
					oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
				End Select
		Case "Xen"
			Select Case sCSPVersion
				Case "4.1.2"
					SetModelAlias = "XenServer602"
				Case Else
					SetModelAlias = "XenServer" 
					oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeInfo
			End Select
		Case "VMware, Inc."
			SetModelAlias = "VMware"
		Case Else
			If Instr(sModel, "(") > 2 Then 
				SetModelAlias = Trim(Left(sModel, Instr(sModel, "(") - 2)) 
			Else 
				SetModelAlias = sModel 
				oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - Alias rule not found.  ModelAlias set to Model value." , LogTypeWarn
			End if 
		End Select

	oEnvironment.Item("Make") = sMake
	oEnvironment.Item("Model") = sModel

	oLogging.CreateEntry "USEREXIT:ModelAliasExit.vbs|SetModelAlias - ModelAlias has been set to " & SetModelAlias, LogTypeInfo
	oLogging.CreateEntry "------------ Departing USEREXIT:ModelAliasExit.vbs|SetModelAlias -------------", LogTypeInfo
End Function
