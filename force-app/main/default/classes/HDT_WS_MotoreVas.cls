/*
 * File: HDT_WS_MotoreVas.cls
 * Project: HERA
 * File Created: Monday, 19th July 2021 10:18:48 am
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 */
public  class HDT_WS_MotoreVas {

    /**
    * @description Send VAS activation callout
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param orderId  
    * @return HDT_WS_Response 
    **/
    public static HDT_WS_Response activationCallout(Id orderId){
        HDT_UTL_VasManagement.HDT_WRP_VASReq req = HDT_UTL_VasManagement.getActivationRequest(orderId);
        HDT_WS_Response res = (HDT_WS_Response) HDT_WS_HTTPServiceCall.sendRequest('VAS.Activation', req,HDT_WS_ArrichmentDataEntityResponse.class);
        return res;
    } 

    /**
    * @description Send VAS deactivation callout
    * @author gabriele.rota@webresults.it | 2021-07-12 
    * @param caseId  
    * @return HDT_WS_Response 
    **/
    public static HDT_WS_Response deactivationCallout(Id caseId){
        HDT_UTL_VasManagement.HDT_WRP_VASReq req = HDT_UTL_VasManagement.getDeactivationRequest(caseId);
        HDT_WS_Response res = (HDT_WS_Response) HDT_WS_HTTPServiceCall.sendRequest('VAS.Deactivation', req,HDT_WS_ArrichmentDataEntityResponse.class);
        return res;
    }
}