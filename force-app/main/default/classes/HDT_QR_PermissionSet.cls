/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 14/05/2021
* @description HDT_QR_PermissionSet.cls
* @history Lorenzo – 14/05/2021 – created class
*/

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

    public List<PermissionSetAssignment> getPermissionSetAssignmentByName(String permissionSetName, String assigneeId){
        return [
            SELECT 
            Id, 
            PermissionSetId, 
            PermissionSet.Name, 
            PermissionSet.ProfileId, 
            PermissionSet.Profile.Name, 
            AssigneeId, 
            Assignee.Name 
            FROM PermissionSetAssignment 
            WHERE PermissionSet.Name = :permissionSetName //ex. 'HDT_SuperUserCPQ'
            AND AssigneeId = :assigneeId //userId
        ];
    }
}