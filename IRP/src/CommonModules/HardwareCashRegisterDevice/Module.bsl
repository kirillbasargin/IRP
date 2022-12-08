
#Region Public

Function ConnectDevice(DriverObject, ConnectionParameters, OutParameters) Export	
	Result = True;

	OutParameters = New Array;
	ConnectionParameters.Insert("ИДУстройства", "");

	DriverObject.УстановитьПараметр("EquipmentType", "ФискальныйРегистратор");

	DriverName				= "";
	DriverDescription		= "";
	DeviceType				= "";
	IntegrationComponent	= False;
	MainDriverInstalled		= False;
	InterfaceRevision		= 2004;
	DriverURL				= "";

	DriverObject.ПолучитьОписание(DriverName, DriverDescription, DeviceType, InterfaceRevision, 
											IntegrationComponent, MainDriverInstalled, DriverURL);
		
	ConnectionParameters.Insert("РевизияИнтерфейса", InterfaceRevision);		
		
	For Each ConnectionParameter Из ConnectionParameters Do
		ParameterValue = ConnectionParameter.Value;
		ParameterName = ConnectionParameter.Key;
		DriverObject.УстановитьПараметр(ParameterName, ParameterValue) 
	EndDo;	

	Response = DriverObject.Подключить(ConnectionParameters.ИДУстройства);
	
	If Not Response Then
		Result = False;
	EndIf;
	
	Return Result;	
EndFunction

Function DisconnectDevice(DriverObject, Parameters, ConnectionParameters, OutParameters) Export	
	Result = True;	
	OutParameters = New Array;	
	DriverObject.Отключить(ConnectionParameters.ИДУстройства);	
	Return Result;	
EndFunction

Function RunCommand(Command, InParameters = Undefined, OutParameters = Undefined, DriverObject, Parameters, ConnectionParameters) Export
	Result = True;
	
	OutParameters = New Array;
	
	If Command = "TestDevice" ИЛИ Command = "CheckHealth" Then
		Result = TestDevice(DriverObject, Parameters, ConnectionParameters, OutParameters);
	Else
		OutParameters.Add(999);
		OutParameters.Add(RL().s1 + Command);
		Result = False;		
	EndIf;
	
	Return Result;
EndFunction

Function OpenShift(DriverObject, ConnectionParameters) Export
	Result = HardwareUniversalDriverClient.OpenShift(DriverObject, ConnectionParameters.ID);
	Return Result;
EndFunction

Function CloseShift(DriverObject, ConnectionParameters) Export
	Result = HardwareUniversalDriverClient.CloseShift(DriverObject, ConnectionParameters.ID);
	Return Result;
EndFunction

Function ReportX(DriverObject, ConnectionParameters) Export
	Result = HardwareUniversalDriverClient.ReportX(DriverObject, ConnectionParameters.ID);
	Return Result;
EndFunction
 
#EndRegion

#Region Public_AllTypeDevice

Function TestDevice(DriverObject, Parameters, ConnectionParameters, OutParameters) Export
	Result			= True;
	TestResult		= "";
	DemoIsActivated = "";
	
	For Each Parameter Из Parameters Do
		If Left(Parameter.Key, 2) = "P_" Then
			ParameterValue = Parameter.Value;
			ParameterName = Mid(Parameter.Key, 3);
			Response = DriverObject.УстановитьПараметр(ParameterName, ParameterValue); 
		EndIf;
	EndDo;
	
	Try
		Response = DriverObject.ТестУстройства(TestResult, DemoIsActivated);
	
		If Response Then
			OutParameters.Clear();
			OutParameters.Add(0);
		Else
			Result = False;
			OutParameters.Clear();
			OutParameters.Add(999);
		EndIf;
		OutParameters.Add(TestResult);
		OutParameters.Add(DemoIsActivated);
	
	Except
		Result = False;
		OutParameters.Clear();
		OutParameters.Add(999);
		OutParameters.Add(RL().s2 + Chars.LF + ErrorDescription());
	EndTry;
	
	Return Result;
EndFunction

#EndRegion

#Region Private

Function RL()
	ReturnValue = New Structure;
	ReturnValue.Insert("s1", "Unknown command: ");
	ReturnValue.Insert("s2", "Error calling method TestDevice:");
	Return ReturnValue;
EndFunction

#EndRegion