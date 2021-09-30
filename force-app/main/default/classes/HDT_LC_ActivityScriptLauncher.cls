/**
 * @description       : Controller for HDT_LCP_ActivityScriptLauncher
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-30
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_LC_ActivityScriptLauncher {
    
    /**
    * @description Get script name and target
    * @author gabriele.rota@webresults.it | 2021-09-30 
    * @param activityId  
    * @return HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig
    **/
    @AuraEnabled
    public static HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig getScriptConfig(Id activityId){
        try {
            return HDT_SRV_ScriptManager.getActivityScriptConfig(activityId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
