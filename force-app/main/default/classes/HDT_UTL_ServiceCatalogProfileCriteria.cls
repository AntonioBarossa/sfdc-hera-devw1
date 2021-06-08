global inherited sharing class HDT_UTL_ServiceCatalogProfileCriteria implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {
    HDT_QR_PermissionSet permQr = new HDT_QR_PermissionSet();
    global boolean evaluate(Object args) {
        Map<String,Object> argsMap = (Map<String,Object>) args;
 		Map<String,HDT_ServiceCatalogProfileFilter__mdt> listMet = HDT_ServiceCatalogProfileFilter__mdt.getAll();
        String userId = userinfo.getUserId();
        String us= userinfo.getUserType();
        SObject action = (SObject) argsMap.get('action'); //phase transition detail
        String method = (String) argsMap.get('method');
        boolean res = false;
        if('CommunityUser'.equalsIgnoreCase(method)){
            if (!'Standard'.Equals(us)){
                res = true;
            }
        }else if ('ServiceUser'.equalsIgnoreCase(method)){
            if ('Standard'.Equals(us)){
                res = true;
            }
        }
        else{
            HDT_ServiceCatalogProfileFilter__mdt permissionName = listMet.get(method);
            System.debug('**********Permission:'+permissionName);
            
            if(permissionName != null){
                SetupEntityAccess obj = permQr.getSetupEntityAccess(permissionName.Visibility__c);
                System.debug('*********:' + obj);
                if(obj != null){  
                    List<PermissionSetAssignment> perAssign = permQr.getPermissionSetAssignment(obj.ParentId,userId);                
                    if(perAssign != null && perAssign.size()> 0){
                        res = true;
                    }    
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