public inherited sharing class HDT_TRH_WasteAdministrationTaxBreaks extends HDT_TRH_TriggerHandler
	{
			
	public override void beforeInsert(){
		replaceBreaks();
	}
	public override void beforeUpdate(){
		replaceBreaks();
	}
	private void replaceBreaks() {
	    for (WasteAdministrationTaxBreaks__c record : (List<WasteAdministrationTaxBreaks__c>) Trigger.new) {
			if(record.TextRequest__c != null){
				String newTextRequest = record.TextRequest__c.replaceAll('[\\n\\r]+', '');
				record.TextRequest__c = newTextRequest;
			}
			if(record.TextRemove__c != null){
				String newTextRemove = record.TextRemove__c.replaceAll('[\\n\\r]+', '');
				record.TextRemove__c = newTextRemove;
			}
    }
	}
	}