

Function InitPrintParam() Export
	Param = New Structure();
	Param.Insert("Result", New SpreadsheetDocument);
	Return  Param; 
EndFunction