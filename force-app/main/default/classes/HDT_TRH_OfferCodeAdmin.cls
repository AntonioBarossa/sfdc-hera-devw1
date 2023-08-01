public with sharing class HDT_TRH_OfferCodeAdmin extends HDT_TRH_TriggerHandler{
    public override void beforeInsert(){
        HDT_UTL_OfferCodeAdmin.handleProduct(Trigger.new);
    }

    public override void beforeUpdate(){
        List <OfferCode32Admin__c> offerToUpdate=new List<OfferCode32Admin__c>();
        for(OfferCode32Admin__c offCode :(List <OfferCode32Admin__c>) Trigger.new){
            OfferCode32Admin__c offer=(OfferCode32Admin__c) Trigger.oldMap.get(offCode.Id);
            if (offCode.Exported__c==offer.Exported__c) {
                offerToUpdate.add(offCode);
            }
        }
        if(!offerToUpdate.isEmpty()){
            HDT_UTL_OfferCodeAdmin.handleProduct(offerToUpdate);
        }
    }
}