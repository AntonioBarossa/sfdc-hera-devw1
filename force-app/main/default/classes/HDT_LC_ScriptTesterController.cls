/**
 * @description       : Script test tab controller
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-20
 * @last modified by  : gabriele.rota@webresults.it
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2021-09-20   gabriele.rota@webresults.it   Initial Version
**/
public with sharing class HDT_LC_ScriptTesterController {
    
    /**
    * @description Get parent scripts
    * @author gabriele.rota@webresults.it | 2021-09-20 
    * @return List<ScriptConfig__c> 
    **/
    @AuraEnabled
    public static List<ScriptConfig__c> getScripts(){
        try {
            return [SELECT Name, ContextObject__c, CreatedBy.Name FROM ScriptConfig__c
                WHERE ScriptType__c='Processo' WITH SECURITY_ENFORCED ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
