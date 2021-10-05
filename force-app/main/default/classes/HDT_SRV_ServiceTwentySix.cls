/**
 * @description       : Utility class for calling Service 26
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-08-12
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_SRV_ServiceTwentySix {

    /**
    * @description Send Service 26 callout
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param orderId  
    * @return HDT_WS_ArrichmentDataEntityResponse 
    **/
    public static HDT_WS_ArrichmentDataEntityResponse callService26(Id orderId) {
        HDT_UTL_ServiceTwentySix reqClass = new HDT_UTL_ServiceTwentySix();
        HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix req = reqClass.startProcess(orderId);
        HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse) HDT_WS_HTTPServiceCall.sendRequest('VAS.Service26', req, HDT_WS_ArrichmentDataEntityResponse.class);
        Case logCase = new Case();
        logCase.Causal__c = 'CALLOUT-Service26';
        logCase.Note__c = JSON.serializePretty(req);
        logCase.Description = JSON.serialize(res);
        Database.insert(logCase);
        return res;
    }
}