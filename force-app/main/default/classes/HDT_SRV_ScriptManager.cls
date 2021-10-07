/**
 * @description       : Service class for Script CB
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-29
 * @last modified by  : gabriele.rota@webresults.it
**/
public inherited sharing class HDT_SRV_ScriptManager {

    private static final String ORDER_RT_VAS = 'HDT_RT_VAS';

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
        config.scriptTarget = orderParentId;

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
                    config.scriptName = 'Mini Vocal Order';
                }
                when 'Vocal Order' {
                    for (HDT_ScriptPerCommOffer__mdt scriptPerOffer:HDT_ScriptPerCommOffer__mdt.getAll().values()) {
                        if (scriptPerOffer.OfferCode__c==productName) {
                            config.scriptName = scriptPerOffer.ScriptName__c;
                            break;
                        }
                    }
                }
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
