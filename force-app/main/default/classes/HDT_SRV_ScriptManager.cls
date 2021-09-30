/**
 * @description       : Service class for Script CB
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-29
 * @last modified by  : gabriele.rota@webresults.it
**/
public inherited sharing class HDT_SRV_ScriptManager {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();
    
    /**
    * @description Get script name and target for given order
    * @author gabriele.rota@webresults.it | 2021-09-29 
    * @param orderParentId  
    * @return HDT_WRP_ScriptConfig
    **/
    public static HDT_WRP_ScriptConfig getOrderScriptConfig(Id orderParentId){

        HDT_WRP_ScriptConfig config = new HDT_WRP_ScriptConfig();

        Order parentOrder = orderQr.getRecordById(orderParentId);
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParentId);

        Order targetOrder = orderQr.getRecordById(childOrders.get(0).Id);
        List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQr.getPrimaryRecord(targetOrder.SBQQ__Quote__c);
        Id productId = quoteLineList[0].SBQQ__Product__c;

        config.scriptTarget = targetOrder.Id;

        if (parentOrder.SignatureMethod__c=='OTP Remoto' || parentOrder.SignatureMethod__c=='OTP Coopresenza') {
            config.scriptName = 'Mini Vocal Order';
        }

        if (parentOrder.SignatureMethod__c=='Vocal Order') {
            List<ScriptConfig__c> scripts = [SELECT Name FROM ScriptConfig__c WHERE Product__c=:productId WITH SECURITY_ENFORCED LIMIT 1];
            if (!scripts.isEmpty()) {
                config.scriptName = scripts[0].Name;
            }
        }

        return config;
    }

    /**
    * @description Get script name and target for given activity
    * @author gabriele.rota@webresults.it | 2021-09-29 
    * @param activityId  
    * @return HDT_WRP_ScriptConfig
    **/
    public static HDT_WRP_ScriptConfig getActivityScriptConfig(Id activityId){

        HDT_WRP_ScriptConfig config = new HDT_WRP_ScriptConfig();

        wrts_prcgvr__Activity__c activity = HDT_QR_ActivityCustom.getActivityByRecordId(activityId)[0];
        config.scriptTarget = activity.Order__c;

        switch on activity.Type__c {
            when 'Quality Call'{
                config.scriptName = 'Quality call';
            }
            when 'Comfort Call'{
                config.scriptName = 'Comfort call';
            }
        }

        return config;
    }

    public class HDT_WRP_ScriptConfig{
        @AuraEnabled public String scriptName {get;set;}
        @AuraEnabled public Id scriptTarget {get;set;}
    }
}
