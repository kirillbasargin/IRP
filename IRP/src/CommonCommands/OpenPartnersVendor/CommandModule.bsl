&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	//@skip-check use-non-recommended-method
	Сообщить("1");
	Filters = New Structure("Vendor", True);
	OpenForm("Catalog.Partners.ListForm", New Structure("Filter, FormTitle", Filters, R().Form_006), , 2);
EndProcedure