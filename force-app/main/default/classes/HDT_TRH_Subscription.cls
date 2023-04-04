/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_DocumentalActivity
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_Subscription extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        System.debug('Before Insert Sub: ' + trigger.new);
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        HDT_UTL_SubscriptionProcess.fakeMoveOutMoveInForOffers(trigger.new);
        HDT_UTL_SubscriptionProcess.adjustVasContractBeforeInsert(trigger.new);
        HDT_UTL_SubscriptionProcess.alignFields(trigger.new);
    }
    public override void beforeUpdate(){
            System.debug('Before Update Sub: ' + trigger.new);
            HDT_UTL_SubscriptionProcess.adjustLookup(trigger.new,Trigger.oldMap);
    }
    public override void afterInsert(){
        System.debug('After Insert Sub: ' + trigger.new);
        HDT_UTL_SubscriptionProcess.dmlOnAfterInsert();
    }
}