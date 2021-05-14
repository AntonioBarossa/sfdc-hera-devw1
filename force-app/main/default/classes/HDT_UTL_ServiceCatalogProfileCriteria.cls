global inherited sharing class HDT_UTL_ServiceCatalogProfileCriteria implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {
    HDT_QR_PermissionSet permQr = new HDT_QR_PermissionSet();
    global boolean evaluate(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
 		Map<String,HDT_ServiceCatalogProfileFilter__mdt> listMet = HDT_ServiceCatalogProfileFilter__mdt.getAll();
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
		HDT_ServiceCatalogProfileFilter__mdt permissionName = listMet.get(method);
        String userId = userinfo.getUserId();
        System.debug('**********Permission:'+permissionName);
        boolean res = false;
        if(permissionName != null){
            SetupEntityAccess obj = permQr.getSetupEntityAccess(permissionName.Visibility__c);
            if(obj != null){  
				List<PermissionSetAssignment> perAssign = permQr.getPermissionSetAssignment(obj.ParentId,userId);                   
                if(perAssign != null){
                    res = true;
                }    
            }
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