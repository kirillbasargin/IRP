
// Print command handler.
//
// Parameters:
//	CommandParameter - Arbitrary - contains a reference to the object for which the print command was executed.
//	CommandExecuteParameters - CommandExecuteParameters - command execute parameters.
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	//{{_PRINT_WIZARD(SalesOrderPrint)
	Spreadsheet = New SpreadsheetDocument;
	SalesOrderPrint(Spreadsheet, CommandParameter);

	Spreadsheet.ShowGrid = False;
	Spreadsheet.Protection = False;	
	Spreadsheet.ReadOnly = False;	
	Spreadsheet.ShowHeaders = False;
	Spreadsheet.Show();
	//}}
EndProcedure

// Print command handler on the server.
//
// Parameters:
//	Spreadsheet - SpreadsheetDocument - spreadsheet document to fill out and print.
//	CommandParameter - Arbitrary - contains a reference to the object for which the print command was executed.
&AtServer
Procedure SalesOrderPrint(Spreadsheet, CommandParameter)
	Spreadsheet = Documents.SalesOrder.SalesOrderPrint(CommandParameter);
EndProcedure
