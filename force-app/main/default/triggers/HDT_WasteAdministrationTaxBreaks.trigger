trigger HDT_WasteAdministrationTaxBreaks on WasteAdministrationTaxBreaks__c(before insert,before update){

	new HDT_TRH_WasteAdministrationTaxBreaks().run();
}