public with sharing class HDT_QR_PermissionSet {
    public List<PermissionSetAssignment> getPermissionSetAssignment(String permissionsetid,String assigneeId){
        return [SELECT Id FROM PermissionSetAssignment where permissionsetid = :permissionsetid AND assigneeId = :assigneeId];  
    }
    public SetupEntityAccess getSetupEntityAccess(String devName){
        
        List<SetupEntityAccess> listSet = [SELECT Parentid FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM CustomPermission where Developername = :devName)];
        if(listSet != null && listSet.size() > 0 ){
            return listSet[0];
        }
        else{
        	return null;    
        }
    }    
}