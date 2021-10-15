/**
 * @description       : Service class for Script CB
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-29
 * @last modified by  : gabriele.rota@webresults.it
**/
public inherited sharing class HDT_SRV_ScriptManager {

    private static final String ORDER_RT_VAS = 'HDT_RT_VAS';
    private static final String DECISIONAL_TYPE = 'Decisionale';

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();

    /**
    * @description 
    * @author gabriele.rota@webresults.it | 2021-15-10 
    * @param recordId  
    * @return List<HDT_WRP_ScriptConfig>
    **/
    public static List<HDT_WRP_ScriptConfig> getScriptConfig(Id recordId) {
        String sObjectName = recordId.getSObjectType().getDescribe().getName();

        List<HDT_WRP_ScriptConfig> configs;
        switch on sObjectName {
            when 'Order' {
                configs = getOrderScriptConfig(recordId);
            }
            when 'wrts_prcgvr__Activity__c'{
                configs = getActivityScriptConfig(recordId);
            }
        }

        checkScriptType(configs);
        return configs;
    }
    
    /**
    * @description Get script name and target for given order
    * @author gabriele.rota@webresults.it | 2021-09-29 
    * @param orderParentId  
    * @return List<HDT_WRP_ScriptConfig>
    **/
    private static List<HDT_WRP_ScriptConfig> getOrderScriptConfig(Id orderParentId){

        List<HDT_WRP_ScriptConfig> configs = new List<HDT_WRP_ScriptConfig>();

        Order parentOrder = orderQr.getRecordById(orderParentId);
        
        Id commOfferOrderId;
        for (Order childOrder:orderQr.getChildOrdersByParentId(orderParentId)) {
            if (childOrder.RecordType.DeveloperName!=ORDER_RT_VAS) {
                commOfferOrderId = childOrder.Id;
                break;
            }
        }

        if (String.isNotBlank(commOfferOrderId)) {
            Order targetOrder = orderQr.getRecordById(commOfferOrderId);

            List<SBQQ__QuoteLine__c> quoteLineList = quoteLineQr.getPrimaryRecord(targetOrder.SBQQ__Quote__c);
            String productName = quoteLineList[0].SBQQ__Product__r.ProductCode;

            switch on parentOrder.SignatureMethod__c {
                when 'OTP Remoto','OTP Coopresenza' {
                    HDT_WRP_ScriptConfig config = new HDT_WRP_ScriptConfig();
                    config.scriptTarget = orderParentId;
                    config.scriptName = 'Mini Vocal Order';
                    configs.add(config);
                }
                when 'Vocal Order' {
                    for (HDT_ScriptPerCommOffer__mdt scriptPerOffer:HDT_ScriptPerCommOffer__mdt.getAll().values()) {
                        if (scriptPerOffer.OfferCode__c==productName) {
                            HDT_WRP_ScriptConfig config = new HDT_WRP_ScriptConfig();
                            config.scriptTarget = orderParentId;
                            config.scriptName = scriptPerOffer.ScriptName__c;
                            configs.add(config);
                        }
                    }
                }
            }
        }

        return configs;
    }

    /**
    * @description Get script name and target for given activity
    * @author gabriele.rota@webresults.it | 2021-09-29 
    * @param activityId  
    * @return List<HDT_WRP_ScriptConfig>
    **/
    private static List<HDT_WRP_ScriptConfig> getActivityScriptConfig(Id activityId){

        List<HDT_WRP_ScriptConfig> configs = new List<HDT_WRP_ScriptConfig>();

        wrts_prcgvr__Activity__c activity = HDT_QR_ActivityCustom.getActivityByRecordId(activityId)[0];

        switch on activity.Type__c {
            when 'Quality Call'{
                HDT_WRP_ScriptConfig config = new HDT_WRP_ScriptConfig();
                config.scriptTarget = activity.Order__c;
                config.scriptName = 'Quality call';
                configs.add(config);
            }
            when 'Comfort Call'{
                HDT_WRP_ScriptConfig config = new HDT_WRP_ScriptConfig();
                config.scriptTarget = activity.Order__c;
                config.scriptName = 'Comfort call';
                configs.add(config);
            }
        }

        return configs;
    }

    /**
    * @description Check if given scripts are decisional
    * @author gabriele.rota@webresults.it | 2021-10-15 
    * @param configs 
    **/
    private static void checkScriptType(List<HDT_WRP_ScriptConfig> configs){

        Set<String> scriptNames = new Set<String>();
        for (HDT_WRP_ScriptConfig config:configs) {
            scriptNames.add(config.scriptName);
        }

        Map<String,Boolean> scriptTypeMap = new Map<String,Boolean>();
        for (ScriptConfig__c script:[SELECT Name, (SELECT Id FROM ChildSections__r WHERE ScriptType__c=:DECISIONAL_TYPE)
            FROM ScriptConfig__c WHERE Name IN :scriptNames WITH SECURITY_ENFORCED]) {
            scriptTypeMap.put(script.Name, !script.ChildSections__r.isEmpty());
        }

        for (HDT_WRP_ScriptConfig config:configs) {
            config.isScriptDecisional = scriptTypeMap.get(config.scriptName);
        }
    }

    public class HDT_WRP_ScriptConfig{
        @AuraEnabled public String scriptName {get;set;}
        @AuraEnabled public Id scriptTarget {get;set;}
        @AuraEnabled public Boolean isScriptDecisional {get;set;}
    }
}
