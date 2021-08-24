/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_DocumentSendTracking
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_DocumentSendTracking extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
    }
}
