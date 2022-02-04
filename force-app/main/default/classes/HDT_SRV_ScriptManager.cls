/**
 * @description       : Service class for Script CB
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-11-09
 * @last modified by  : gabriele.rota@webresults.it
**/
public inherited sharing class HDT_SRV_ScriptManager {

    private static final String ORDER_RT_VAS = 'HDT_RT_VAS';
    private static final String DECISIONAL_TYPE = 'Decisionale';

    @TestVisible
    private static List<HDT_ScriptPerCommOffer__mdt> scriptsMapping = Test.isRunningTest() ? new List<HDT_ScriptPerCommOffer__mdt>() : HDT_ScriptPerCommOffer__mdt.getAll().values();

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_QuoteLine quoteLineQr = new HDT_QR_QuoteLine();

    /**
    * @description Get script configuration for a given record
    * @author gabriele.rota@webresults.it | 2021-15-10 
    * @param recordId  
    * @return List<HDT_WRP_ScriptConfig>
    **/
    public static List<HDT_WRP_ScriptConfig> getScriptConfig(Id recordId) {
        String sObjectName = recordId.getSObjectType().getDescribe().getName();

        List<HDT_WRP_ScriptConfig> configs;
        switch on sObjectName {
            when 'Order' {
                // configs = getOrderScriptConfig(recordId);
                configs = getOrderScriptFlows(recordId);
            }
            when 'wrts_prcgvr__Activity__c'{
                configs = getActivityScriptConfig(recordId);
            }
            when 'CampaignMember'{
                configs = getCampaignMemberScriptConfig(recordId);
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
    // private static List<HDT_WRP_ScriptConfig> getOrderScriptConfig(Id orderParentId){

    //     Order parentOrder = orderQr.getRecordById(orderParentId);
    //     Set<String> offerCodes = new Set<String>();
    //     for (Order childOrder:orderQr.getChildOrdersByParentId(orderParentId)) {

    //         if (String.isNotBlank(childOrder.OrderReference__c)) {
    //             continue;
    //         }

    //         if (String.isNotBlank(childOrder.CommercialProductCode__c)) {
    //             offerCodes.add( childOrder.CommercialProductCode__c );
    //         }
    //     }

    //     Set<String> scriptNames = getOrderScriptsFromMetadata(parentOrder.SignatureMethod__c, offerCodes);
    //     List<HDT_WRP_ScriptConfig> configs = new List<HDT_WRP_ScriptConfig>();
    //     for (String scriptName:scriptNames) {
    //         configs.add(new HDT_WRP_ScriptConfig(orderParentId, scriptName));
    //     }

    //     return configs;
    // }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    private static List<HDT_WRP_ScriptConfig> getOrderScriptFlows(Id orderParentId){

        Order parentOrder = orderQr.getRecordById(orderParentId);
        List<HDT_WRP_ScriptConfig> configs = new List<HDT_WRP_ScriptConfig>();
        Set<String> offerCodes = new Set<String>();
        Set<String> vasNames = new Set<String>();

        try {
            
            for (Order childOrder : orderQr.getChildOrdersByParentId(orderParentId)) {
    
                if (String.isNotBlank(childOrder.OrderReference__c)) {
                    continue;
                }
    
                if('VAS'.equals(childOrder.ProcessType__c)){
                    vasNames.add(childOrder.CommercialProduct__c);
                    continue;
                }
    
                if (String.isNotBlank(childOrder.CommercialProductCode__c)) {
                    offerCodes.add(childOrder.CommercialProductCode__c);
                }
    
            }
    
            List<AggregateResult> offerNames = [SELECT Product2.CategoryFamily__c FROM OrderItem WHERE Product2.ProductCode IN: offerCodes WITH SECURITY_ENFORCED GROUP BY Product2.CategoryFamily__c];
    
            String flowUrl = '';
            String nomeOfferta = '';
    
            if (offerNames.size() > 0){
                for (AggregateResult offerName : offerNames){
                    for (HDT_ScriptPerCommOffer__mdt scriptPerOffer : scriptsMapping) {
                        if (scriptPerOffer.Object__c == 'Order' && scriptPerOffer.SignatureMethod__c == parentOrder.SignatureMethod__c) {
                            if (String.valueOf(offerName.get('CategoryFamily__c')).equalsIgnoreCase(scriptPerOffer.OfferName__c)) {
                                flowUrl = '/flow/' + scriptPerOffer.ScriptFlowName__c +'?idOrdinePadreInput='+ orderParentId +'&offertaInput='+ String.valueOf(offerName.get('CategoryFamily__c')) +'';
                                nomeOfferta = String.valueOf(offerName.get('CategoryFamily__c'));
                                configs.add(new HDT_WRP_ScriptConfig(nomeOfferta, flowUrl));
                            }
                        }
                    }
                }
            }else{
    
                HDT_ScriptPerCommOffer__mdt vasScriptConfig = [SELECT ScriptFlowName__c FROM HDT_ScriptPerCommOffer__mdt WHERE DeveloperName = 'VAS' WITH SECURITY_ENFORCED LIMIT 1];
    
                if (vasScriptConfig != null && vasNames.size() > 0){
                    flowUrl = '/flow/' + vasScriptConfig.ScriptFlowName__c + '?idOrdinePadreInput='+ orderParentId;
                    configs.add(new HDT_WRP_ScriptConfig('VAS', flowUrl));
                }
            }
    
            System.debug(LoggingLevel.DEBUG, 'returned configs list: ' + configs);
            return configs;

        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Si è verificato un errore: ' + e.getStackTraceString());
            throw e;
        }
    }

    @AuraEnabled
    public static String getFlowCampaign(Id campaignMemberId){

        String flowUrl = '';
        String flowName = '';

        Set<String> allowedCampaignTypes = new Set<String>{'Quality Call', 'Comfort Call'};

        CampaignMember campMemb = [SELECT CampaignId, Campaign.Tipology__c, Campaign.FlowType__c FROM CampaignMember WHERE Id =: campaignMemberId WITH SECURITY_ENFORCED];

        if(campMemb != null){

            for (HDT_ScriptPerCommOffer__mdt scriptPerOffer : scriptsMapping) {
    
                if(String.isBlank(campMemb.Campaign.Tipology__c) || !allowedCampaignTypes.contains(campMemb.Campaign.Tipology__c)){
                    if (!String.isBlank(campMemb.Campaign.FlowType__c) && campMemb.Campaign.FlowType__c == scriptPerOffer.OfferName__c && 'Campaign'.equals(scriptPerOffer.Object__c)){
                        flowName = scriptPerOffer.ScriptFlowName__c;
                        continue;
                    }
                }else if (campMemb.Campaign.Tipology__c == scriptPerOffer.ActivityType__c && 'Campaign'.equals(scriptPerOffer.Object__c)){
                    flowName = scriptPerOffer.ScriptFlowName__c;
                    continue; 
                }
            }

            if(!String.isBlank(flowName)){
                return flowUrl = '/flow/' + flowName +'?idCampaignMemberInput='+ campaignMemberId;
            }else{
                return 'flow not found';
            }
            
        }else{
            throw new AuraHandledException('Si è verificato un errore  in fase di get delle informazioni su CampaignMember');
        }
    }

    /**
    * @description Get script name and target for given activity
    * @author gabriele.rota@webresults.it | 2021-09-29 
    * @param activityId  
    * @return List<HDT_WRP_ScriptConfig>
    **/
    private static List<HDT_WRP_ScriptConfig> getActivityScriptConfig(Id activityId){

        wrts_prcgvr__Activity__c activity = HDT_QR_ActivityCustom.getActivityByRecordId(activityId)[0];

        Set<String> scriptNames = getActivityScriptsFromMetadata(activity.Type__c);
        List<HDT_WRP_ScriptConfig> configs = new List<HDT_WRP_ScriptConfig>();
        for (String scriptName:scriptNames) {
            configs.add(new HDT_WRP_ScriptConfig(activity.Order__c, scriptName));
        }
        return configs;
    }

    /**
    * @description Get script name and target for given campaign member
    * @author gabriele.rota@webresults.it | 2021-11-09 
    * @param campMemberId  
    * @return List<HDT_WRP_ScriptConfig>
    **/
    private static List<HDT_WRP_ScriptConfig> getCampaignMemberScriptConfig(Id campMemberId){

        CampaignMember campMember = [SELECT Campaign.ScriptConfig__r.Name FROM CampaignMember WHERE Id=:campMemberId WITH SECURITY_ENFORCED LIMIT 1];

        List<HDT_WRP_ScriptConfig> configs = new List<HDT_WRP_ScriptConfig>();
        if (campMember.Campaign.ScriptConfig__r!=null) {
            configs.add(new HDT_WRP_ScriptConfig(campMemberId, campMember.Campaign.ScriptConfig__r.Name));
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

    /**
    * @description Getting script names for given order(s)
    * @author gabriele.rota@webresults.it | 2021-10-20 
    * @return Set<String>
    **/
    private static Set<String> getOrderScriptsFromMetadata(String signatureMethod, Set<String> offerCodes) {
        Set<String> scriptNames = new Set<String>();
        for (HDT_ScriptPerCommOffer__mdt scriptPerOffer:scriptsMapping) {
            if (scriptPerOffer.Object__c=='Order' && scriptPerOffer.SignatureMethod__c==signatureMethod) {
                if (signatureMethod!='Vocal Order' || offerCodes.contains(scriptPerOffer.OfferCode__c)) {
                    scriptNames.add(scriptPerOffer.ScriptName__c);
                }
            }
        }
        return scriptNames;
    }

    /**
    * @description Getting script names for given activity
    * @author gabriele.rota@webresults.it | 2021-10-20 
    * @return Set<String>
    **/
    private static Set<String> getActivityScriptsFromMetadata(String activityType) {
        Set<String> scriptNames = new Set<String>();
        for (HDT_ScriptPerCommOffer__mdt scriptPerOffer:scriptsMapping) {
            if (scriptPerOffer.Object__c=='Activity' && scriptPerOffer.ActivityType__c==activityType) {
                scriptNames.add(scriptPerOffer.ScriptName__c);
            }
        }
        return scriptNames;
    }

    public class HDT_WRP_ScriptConfig{
        @AuraEnabled public String scriptName {get;set;}
        @AuraEnabled public Id scriptTarget {get;set;}
        @AuraEnabled public Boolean isScriptDecisional {get;set;}

        @AuraEnabled public String offerName {get;set;}
        @AuraEnabled public String flowUrl {get;set;}

        public HDT_WRP_ScriptConfig(Id scrTarget, String scrName) {
            this.scriptTarget = scrTarget;
            this.scriptName = scrName;
        }

        public HDT_WRP_ScriptConfig(String offerName, String flowUrl) {
            this.offerName = offerName;
            this.flowUrl = flowUrl;
        }
    }

}
