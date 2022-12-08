#Region FiscarRegister

Function OpenCashDrawer(DriverObject, ID) Export
	Result = New Structure();
	Result.Insert("Successful", True);
	Result.Insert("ErrorDescription", "");
	Return Result;
EndFunction

Function OpenShift(DriverObject, ID) Export
	Result = New Structure();
	Result.Insert("Successful", True);
	Result.Insert("ErrorDescription", "");
	Return Result;
EndFunction

Function CloseShift(DriverObject, ID) Export
	Result = New Structure();
	Result.Insert("Successful", True);
	Result.Insert("ErrorDescription", "");
	Return Result;
EndFunction

Function ReportX(DriverObject, ID) Export	
	Result = New Structure();
	Result.Insert("Successful", True);
	Result.Insert("ErrorDescription", "");	
	Return Result;	
EndFunction

#EndRegion
