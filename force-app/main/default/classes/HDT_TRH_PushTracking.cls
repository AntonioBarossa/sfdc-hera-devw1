/**
 * @author Sabina Levonja
 * @date 04/06/2021
 * @description HDT_TRH_TriggerHandler Class
 * @history Sabina Levonja 04/06/2021 – Created Class
 */
public inherited sharing class HDT_TRH_PushTracking extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
    }
}