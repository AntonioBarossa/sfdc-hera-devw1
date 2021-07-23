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

    public static HDT_WS_Response activationCallout(Id orderId){
        HDT_UTL_VasManagement.HDT_WRP_VASReq req = HDT_UTL_VasManagement.getActivationRequest(orderId);
        HDT_WS_Response res = (HDT_WS_Response) HDT_WS_HTTPServiceCall.sendRequest('VAS.Activation', req,HDT_WS_ArrichmentDataEntityResponse.class);
        return res;
    } 

    public static HDT_WS_Response deactivationCallout(Id caseId){
        HDT_UTL_VasManagement.HDT_WRP_VASReq req = HDT_UTL_VasManagement.getDisactivationRequest(caseId);
        HDT_WS_Response res = (HDT_WS_Response) HDT_WS_HTTPServiceCall.sendRequest('VAS.Deactivation', req,HDT_WS_ArrichmentDataEntityResponse.class);
        return res;
    }
}