
Procedure ServerEntryPoint(StepsEnablerName, Parameters) Export
	ModelClientServer_V2.ServerEntryPoint(StepsEnablerName, Parameters);
EndProcedure

Function ExtractDataAgreementApArPostingDetailImp(Agreement) Export
	If Not ValueIsFilled(Agreement) Then
		Return Enums.ApArPostingDetail.EmptyRef();
	EndIf;
	Query = New Query();
	Query.Text = 
	"SELECT
	|	Agreements.ApArPostingDetail
	|FROM
	|	Catalog.Agreements AS Agreements
	|WHERE
	|	Agreements.Ref = &Ref";
	Query.SetParameter("Ref", Agreement);
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	If QuerySelection.Next() Then
		Return QuerySelection.ApArPostingDetail;
	EndIf;
	Return Enums.ApArPostingDetail.EmptyRef();
EndFunction
	
Function ConvertQuantityToQuantityInBaseUnit(Bundle, Unit, Quantity) Export
	If TypeOf(Bundle) = Type("CatalogRef.ItemKeys") Then
		Return Catalogs.Units.ConvertQuantityToQuantityInBaseUnit(Bundle, Unit, Quantity).QuantityInBaseUnit;
	ElsIf TypeOf(Bundle) = Type("CatalogRef.Items") Then
		Return Catalogs.Units.Convert(Unit, Bundle.Unit, Quantity);
	EndIf;
EndFunction

Function GetCommissionPercentExecute(Options) Export
	
	Query = New Query;
	Query.Text =
		"SELECT
		|	BankTermsPaymentTypes.Percent
		|FROM
		|	Catalog.BankTerms.PaymentTypes AS BankTermsPaymentTypes
		|WHERE
		|	BankTermsPaymentTypes.Ref = &Ref
		|	AND BankTermsPaymentTypes.PaymentType = &PaymentType
		|	AND BankTermsPaymentTypes.Account = &Account";
	
	Query.SetParameter("Ref", Options.BankTerm);
	Query.SetParameter("PaymentType", Options.PaymentType);
	Query.SetParameter("Account", Options.Account);
	
	QueryResult = Query.Execute();
	
	SelectionDetailRecords = QueryResult.Select();
	
	While SelectionDetailRecords.Next() Do
		Return SelectionDetailRecords.Percent;
	EndDo;

	Return 0;
EndFunction