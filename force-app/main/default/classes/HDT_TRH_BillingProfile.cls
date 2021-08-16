/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/2021
* @description HDT_TRH_BillingProfile 
* @history Sabina Levonja – 04/06/2021 – created class 
*/
public inherited sharing class HDT_TRH_BillingProfile extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
    }
}

