<<<<<<< HEAD
/**
=======
 /**
>>>>>>> 31c107024df6d69a31b23b5f3e36d6922b55218a
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_Opportunity
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_Opportunity extends HDT_TRH_TriggerHandler{
    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
    }
}