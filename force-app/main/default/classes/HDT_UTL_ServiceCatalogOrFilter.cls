@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_ServiceCatalogOrFilter implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {

    HDT_QR_PermissionSet permQr = new HDT_QR_PermissionSet();
    
    global boolean evaluate(Object args) {

        Map<String,Object> argsMap = (Map<String,Object>) args;
        sObject sb = (sObject) argsMap.get('record');
        String objectType = sb.Id.getSObjectType().getDescribe().getName();
        String method = (String) argsMap.get('method');
        boolean res = true;

        if(objectType == 'Case'){
            res = HDT_UTL_ServiceCatalogOrFilterProcess.caseFilter(sb, method);
        }else if ('ServicePoint__c'.equalsIgnoreCase(objectType)){
            res = HDT_UTL_ServiceCatalogOrFilterProcess.servicePointFilter(sb, method);
        }
        else if (objectType == 'AccountStatementFilter__c'){
            res = HDT_UTL_ServiceCatalogOrFilterProcess.accountStatementFilter(sb, method);
        }
        else if(objectType == 'Sale__c')
        {
            res = HDT_UTL_ServiceCatalogOrFilterProcess.checkSalesTari((String)sb.get('Id'), method);
        }
        return res;
    }
}