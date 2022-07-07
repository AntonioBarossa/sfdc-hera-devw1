/**
 * @description       : Utility class for calling Service 26
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-08-12
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_SRV_ServiceTwentySix {
    private static final String REQUEST_PATH = '/activations/catalog-attributes'; 
    /**
    * @description Send Service 26 callout
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param orderId  
    * @return HDT_WS_ArrichmentDataEntityResponse 
    **/
    public static HDT_WS_ArrichmentDataEntityResponse callService26(Id orderId) {
        HDT_UTL_ServiceTwentySix reqClass = new HDT_UTL_ServiceTwentySix();
        HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix req = reqClass.startProcess(orderId);
        HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse) HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WS_ArrichmentDataEntityResponse.class);
        insertCalloutLog('CALLOUT-Service26', req, res);
        return res;
    }

    public static void insertCalloutLog(String message, HDT_WS_Request req, HDT_WS_Response res){
        wrts_prcgvr__Log__c calloutLog = new wrts_prcgvr__Log__c();
        calloutLog.wrts_prcgvr__Code__c = String.valueof(system.now().format('yyyyMMddHHmmssSSS'));
        calloutLog.wrts_prcgvr__Message__c = message;
        calloutLog.wrts_prcgvr__Description__c = 'request: \n'+JSON.serializePretty(req)+'\n\n\n\nresponse:\n'+JSON.serialize(res);
        insert calloutLog;//those debug logs must violate crud permission, those are registered for admins only
    }

    public static void insertCalloutLog(String message, String req, String res){
        wrts_prcgvr__Log__c calloutLog = new wrts_prcgvr__Log__c();
        calloutLog.wrts_prcgvr__Code__c = String.valueof(system.now().format('yyyyMMddHHmmssSSS'));
        calloutLog.wrts_prcgvr__Message__c = message;
        calloutLog.wrts_prcgvr__Description__c = 'request: \n'+req+'\n\n\n\nresponse:\n'+res;
        insert calloutLog;//those debug logs must violate crud permission, those are registered for admins only
    }
}