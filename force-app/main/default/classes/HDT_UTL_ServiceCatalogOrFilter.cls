global inherited sharing class HDT_UTL_ServiceCatalogOrFilter implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {
    HDT_QR_PermissionSet permQr = new HDT_QR_PermissionSet();
    // Classe Utilizzata per i filtri in OR del Processo da catalogo servizi.
  //  'Cluster__c:valore,valore2,valore3?Type:valore1 ,valore2, valore3'
    global boolean evaluate(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
        System.debug('************VALUEOF:' + argsMap);
        sObject sb = (sObject) argsMap.get('record');
        System.debug('************VALUE:'+ sb.Id.getSObjectType().getDescribe().getName());
        String objectType = sb.Id.getSObjectType().getDescribe().getName();
        //Map<String,HDT_ServiceCatalogProfileFilter__mdt> listMet = HDT_ServiceCatalogProfileFilter__mdt.getAll();
        //SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        boolean res = true;
        if ('ServicePoint__c'.equalsIgnoreCase(objectType)){
            res = HDT_UTL_ServiceCatalogOrFilterProcess.servicePointFilter(sb, method);
        }else if(objectType == 'Case'){
            res = HDT_UTL_ServiceCatalogOrFilterProcess.caseFilter(sb, method);
        } else if (objectType == 'AccountStatementFilter__c'){
            res = HDT_UTL_ServiceCatalogOrFilterProcess.accountStatementFilter(sb, method);
        }
        return res;
    }
    /*global object getLinkItems(Object args){
        Map<String,Object> argsMap = (Map<String,Object>) args;
 
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        if(method == 'Prova1'){
            return true;
        }
        else{
            return false;
        }
        
    }
    global object getLinks(Object args){
        Map<String,Object> argsMap = (Map<String,Object>) args;
 
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        if(method == 'Prova1'){
            return true;
        }
        else{
            return false;
        }
        
    }*/
}