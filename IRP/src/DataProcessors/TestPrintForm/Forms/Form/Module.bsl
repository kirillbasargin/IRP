
&AtClient
Procedure OpenPrintForm(Command)
	Param = InitPrintParam();
	Param.Insert("Result", New SpreadsheetDocument); 
	OpenForm("CommonForm.PrintForm", Param);
EndProcedure

&AtServer
Function InitPrintParam()
	Return UniversalPrintServer.InitPrintParam();	
EndFunction

&AtClient
Procedure SetSD(Command)
	Spreadsheet = New SpreadsheetDocument;
	SetSDServer(Spreadsheet);
	Param = InitPrintParam();
	Param.Result = Spreadsheet; 
	Notify("AddTemplate", Param)
EndProcedure		

&AtServer
Procedure SetSDServer(Spreadsheet)
	Ref = Documents.SalesOrder.FindByNumber("3", Date(2021, 1, 1));
	Spreadsheet = Documents.SalesOrder.SalesOrderPrint(Ref);
EndProcedure

