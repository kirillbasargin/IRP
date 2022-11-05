
#Region FORM

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	LocalizationEvents.CreateMainFormItemDescription(ThisObject, "GroupDescriptions");
	AddAttributesAndPropertiesServer.OnCreateAtServer(ThisObject);
	ExtensionServer.AddAttributesFromExtensions(ThisObject, Object.Ref);
	CatAgreementsServer.OnCreateAtServer(Cancel, StandardProcessing, ThisObject, Parameters);
	
	Items.Type.ChoiceList.Clear();
	Items.Type.ChoiceList.Add(Enums.AgreementTypes.Customer);
	Items.Type.ChoiceList.Add(Enums.AgreementTypes.Vendor);
	
	If FOServer.IsUseCommissionTrading() Then
		Items.Type.ChoiceList.Add(Enums.AgreementTypes.Consignor);
		Items.Type.ChoiceList.Add(Enums.AgreementTypes.TradeAgent);
	EndIf;
	
	If Parameters.Key.IsEmpty() Then
		SetVisibilityAvailability(Object, ThisObject);
	EndIf;
EndProcedure

&AtServer
Procedure OnReadAtServer(CurrentObject)
	SetVisibilityAvailability(CurrentObject, ThisObject);
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	AddAttributesAndPropertiesServer.BeforeWriteAtServer(ThisObject, Cancel, CurrentObject, WriteParameters);
EndProcedure

&AtServer
Procedure AfterWriteAtServer(CurrentObject, WriteParameters)
	SetVisibilityAvailability(CurrentObject, ThisObject);
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source, AddInfo = Undefined) Export
	If EventName = "UpdateAddAttributeAndPropertySets" Then
		AddAttributesCreateFormControl();
	EndIf;
EndProcedure

&AtClient
Procedure FormSetVisibilityAvailability() Export
	SetVisibilityAvailability(Object, ThisObject);
EndProcedure

&AtClientAtServerNoContext
Procedure SetVisibilityAvailability(Object, Form)
	IsStandard = Object.Kind = PredefinedValue("Enum.AgreementKinds.Standard");
	IsRegular  = Object.Kind = PredefinedValue("Enum.AgreementKinds.Regular");
	ApArByStandardAgreements = Object.ApArPostingDetail = PredefinedValue("Enum.ApArPostingDetail.ByStandardAgreement");
	ApArByDocuments          = Object.ApArPostingDetail = PredefinedValue("Enum.ApArPostingDetail.ByDocuments");

	IsCustomer   = Object.Type = PredefinedValue("Enum.AgreementTypes.Customer");
	IsVendor     = Object.Type = PredefinedValue("Enum.AgreementTypes.Vendor");
	IsConsignor  = Object.Type = PredefinedValue("Enum.AgreementTypes.Consignor");
	IsTradeAgent = Object.Type = PredefinedValue("Enum.AgreementTypes.TradeAgent");

	Form.Items.ItemSegment.Visible = IsCustomer And Not IsStandard;

	Form.Items.StandardAgreement.Visible = ApArByStandardAgreements;

	Form.Items.ApArPostingDetail.ReadOnly       = IsStandard;
	Form.Items.PriceType.Visible                = IsRegular;
	Form.Items.PriceIncludeTax.Visible          = IsRegular;
	Form.Items.NumberDaysBeforeShipment.Visible = IsRegular;
	Form.Items.Store.Visible                    = IsRegular;
	
	If IsConsignor Or IsTradeAgent Then
		Form.Items.GroupCreditlimitAndAging.Visible = False;
	Else
		Form.Items.GroupCreditlimitAndAging.Visible = True;
		Form.Items.UseCreditLimit.ReadOnly = Not IsCustomer Or IsStandard;
		Form.Items.CreditLimitAmount.Visible            = Object.UseCreditLimit And IsCustomer And Not IsStandard;
		Form.Items.CurrencyMovementTypeCurrency.Visible = Object.UseCreditLimit And IsCustomer And Not IsStandard;
		Form.Items.PaymentTerm.Visible = ApArByDocuments And (IsCustomer Or IsVendor) And Not IsStandard;
	EndIf;
EndProcedure

#EndRegion

#Region COMPANY

&AtClient
Procedure CompanyStartChoice(Item, ChoiceData, StandardProcessing)
	OpenSettings = DocumentsClient.GetOpenSettingsStructure();
	OpenSettings.ArrayOfFilters = New Array();
	OpenSettings.ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("DeletionMark", True, DataCompositionComparisonType.NotEqual));
	OpenSettings.ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("OurCompany", True, DataCompositionComparisonType.Equal));
	OpenSettings.FillingData = New Structure("OurCompany", True);
	DocumentsClient.CompanyStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing, OpenSettings);
EndProcedure

&AtClient
Procedure CompanyEditTextChange(Item, Text, StandardProcessing)
	ArrayOfFilters = New Array();
	ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("DeletionMark", True, ComparisonType.NotEqual));
	ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("OurCompany", True, ComparisonType.Equal));
	DocumentsClient.CompanyEditTextChange(Object, ThisObject, Item, Text, StandardProcessing, ArrayOfFilters);
EndProcedure

#EndRegion

#Region PARTNER

&AtClient
Procedure PartnerOnChange(Item)
	Object.LegalName = DocumentsServer.GetLegalNameByPartner(Object.Partner, Object.LegalName);
EndProcedure

#EndRegion

#Region LEGAL_NAME

&AtClient
Procedure LegalNameStartChoice(Item, ChoiceData, StandardProcessing)
	OpenSettings = DocumentsClient.GetOpenSettingsStructure();
	OpenSettings.ArrayOfFilters = New Array();
	OpenSettings.ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("DeletionMark", True, DataCompositionComparisonType.NotEqual));
	OpenSettings.ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("OurCompany", False, DataCompositionComparisonType.Equal));
	OpenSettings.FormParameters = New Structure();
	If ValueIsFilled(Object.Partner) Then
		OpenSettings.FormParameters.Insert("Partner", Object.Partner);
		OpenSettings.FormParameters.Insert("FilterByPartnerHierarchy", True);
	EndIf;
	OpenSettings.FillingData = New Structure("OurCompany", False);
	If ValueIsFilled(Object.Partner) Then
		OpenSettings.FillingData.Insert("Partner", Object.Partner);
	EndIf;
	DocumentsClient.CompanyStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing, OpenSettings);
EndProcedure

&AtClient
Procedure LegalNameEditTextChange(Item, Text, StandardProcessing)
	ArrayOfFilters = New Array();
	ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("DeletionMark", True, ComparisonType.NotEqual));
	ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("OurCompany", False, ComparisonType.Equal));
	AdditionalParameters = New Structure();
	If ValueIsFilled(Object.Partner) Then
		AdditionalParameters.Insert("Partner", Object.Partner);
		AdditionalParameters.Insert("FilterByPartnerHierarchy", True);
	EndIf;
	DocumentsClient.CompanyEditTextChange(Object, ThisObject, Item, Text, StandardProcessing, ArrayOfFilters, AdditionalParameters);
EndProcedure

#EndRegion

#Region PARTNER_SEGMENT

&AtClient
Procedure PartnerSegmentStartChoice(Item, ChoiceData, StandardProcessing)
	OpenSettings = DocumentsClient.GetOpenSettingsStructure();
	OpenSettings.ArrayOfFilters = New Array();
	OpenSettings.ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("DeletionMark", True, DataCompositionComparisonType.NotEqual));
	OpenSettings.ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("Managers", False, DataCompositionComparisonType.Equal));
	OpenSettings.FormParameters = New Structure();
	OpenSettings.FillingData = New Structure("Managers", False);
	DocumentsClient.PartnerSegmentStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing, OpenSettings);
EndProcedure

&AtClient
Procedure PartnerSegmentEditTextChange(Item, Text, StandardProcessing)
	ArrayOfFilters = New Array();
	ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("DeletionMark", True, ComparisonType.NotEqual));
	ArrayOfFilters.Add(DocumentsClientServer.CreateFilterItem("Managers", False, ComparisonType.Equal));
	DocumentsClient.PartnerSegmentEditTextChange(Object, ThisObject, Item, Text, StandardProcessing, ArrayOfFilters);
EndProcedure

#EndRegion

#Region _TYPE

&AtClient
Procedure TypeOnChange(Item)
	If Object.Type <> PredefinedValue("Enum.AgreementTypes.Customer") Then
		Object.UseCreditLimit = False;
		Object.CreditLimitAmount = 0;
	EndIf;
	
	SetVisibilityAvailability(Object, ThisObject);
EndProcedure

#EndRegion

#Region AP_AP_POSTING_DETAILS

&AtClient
Procedure ApArPostingDetailOnChange(Item)
	If Object.ApArPostingDetail <> PredefinedValue("Enum.ApArPostingDetail.ByStandardAgreement") Then
		Object.StandardAgreement = Undefined;
	EndIf;
	If Object.ApArPostingDetail <> PredefinedValue("Enum.ApArPostingDetail.ByDocuments") Then
		Object.PaymentTerm = Undefined;
	EndIf;
	SetVisibilityAvailability(Object, ThisObject);	
EndProcedure

#EndRegion

#Region KIND

&AtClient
Procedure KindOnChange(Item)
	If Object.Kind = PredefinedValue("Enum.AgreementKinds.Standard") Then
		Object.ApArPostingDetail = PredefinedValue("Enum.ApArPostingDetail.ByAgreements");
		Object.StandardAgreement = Undefined;
		Object.PriceType = Undefined;
		Object.PaymentTerm = Undefined;
	EndIf;
	SetVisibilityAvailability(Object, ThisObject);	
EndProcedure

#EndRegion

#Region USE_CREDIT_LIMIT

&AtClient
Procedure UseCreditLimitOnChange(Item)
	If Not Object.UseCreditLimit Then
		Object.CreditLimitAmount = 0;
	EndIf;
	SetVisibilityAvailability(Object, ThisObject);	
EndProcedure

#EndRegion

&AtClient
Procedure DescriptionOpening(Item, StandardProcessing) Export
	LocalizationClient.DescriptionOpening(Object, ThisObject, Item, StandardProcessing);
EndProcedure

#Region AddAttributes

&AtClient
Procedure AddAttributeStartChoice(Item, ChoiceData, StandardProcessing) Export
	AddAttributesAndPropertiesClient.AddAttributeStartChoice(ThisObject, Item, StandardProcessing);
EndProcedure

&AtServer
Procedure AddAttributesCreateFormControl()
	AddAttributesAndPropertiesServer.CreateFormControls(ThisObject);
EndProcedure

#EndRegion