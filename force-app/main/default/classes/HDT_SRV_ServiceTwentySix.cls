/**
 * @description       : 
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-08-12
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_SRV_ServiceTwentySix {

    public static HDT_WS_Response callService26(Id orderId) {
        HDT_UTL_ServiceTwentySix reqClass = new HDT_UTL_ServiceTwentySix();
        HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix req = reqClass.startProcess(orderId);
        HDT_WS_Response res = (HDT_WS_Response) HDT_WS_HTTPServiceCall.sendRequest('VAS.Service26', req, HDT_WS_ArrichmentDataEntityResponse.class);
        return res;
    }
}
