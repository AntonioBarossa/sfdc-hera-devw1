/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 25/05/2021
* @description HDT_TRH_ActivityCustom
* @history Lorenzo – 25/05/2021 – created class
*/
public inherited sharing class  HDT_TRH_ActivityCustom extends HDT_TRH_TriggerHandler {
	
    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        HDT_UTL_Scarti.setLookupFields(trigger.new);
    }

 	public override void beforeDelete(){}
 	public override void afterDelete(){}
  	public override void afterUndelete(){}
    
    public override void beforeUpdate(){}

    public override void afterUpdate(){

        HDT_UTL_ActivityCustomProcess.changeAssignRelatedRecord(trigger.new,trigger.old);

        // @Picchiri 08.06.21 Credit Check Annullamento Ordine
        HDT_UTL_ActivityCustomProcess.annullamentoActivityCustom(trigger.new,trigger.old);

        // @Picchiri 14.06.21 Credit innesco credi check al cambio dello stato        
        HDT_UTL_ActivityCustomProcess.creditCheckKoPrecedenteCliente(trigger.new,trigger.old);

        //cancel orders from quality call activities with 'No esito' and ActiveMonitoring__c = true
        HDT_UTL_ActivityCustomProcess.cancelQualityNoResult(trigger.new,trigger.old);
        
       // marco.arci@webresults.it 01/09/2021 gestione scarti documentali
       HDT_UTL_Scarti.updatePraticaForScartoDocumentale(trigger.new, trigger.old);

    }

    public override void afterInsert(){
        HDT_UTL_Scarti.checkForEsitiIntermedi(trigger.new);
    }   

}