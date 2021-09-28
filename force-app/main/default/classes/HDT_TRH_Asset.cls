/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 04/06/2021
 * @description HDT_TRH_Asset Classes
 * @history Sabina Levonja 04/06/2021 – Created class
 */

public inherited sharing class HDT_TRH_Asset extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        HDT_UTL_AssetStatusVas.processAssets(Trigger.new); //gabriele.rota@webresults.it | 2021-09-27 
    }

    public override void beforeUpdate(){
        HDT_UTL_AssetStatusVas.processAssets(Trigger.new); //gabriele.rota@webresults.it | 2021-09-28 
    }
}
