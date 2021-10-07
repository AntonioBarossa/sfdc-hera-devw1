/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 14/05/2021
* @description HDT_QR_PermissionSet.cls
* @history Lorenzo – 14/05/2021 – created class
*/

public with sharing class HDT_QR_PermissionSet {

    public List<PermissionSetAssignment> getPermissionSetAssignment(String permissionsetid,String assigneeId){
        return [SELECT Id FROM PermissionSetAssignment where permissionsetid = :permissionsetid AND assigneeId = :assigneeId /* WITH SECURITY_ENFORCED*/ ];  
    }
    public SetupEntityAccess getSetupEntityAccess(String devName){
        
        List<SetupEntityAccess> listSet = [SELECT Parentid FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM CustomPermission where Developername = :devName) /*WITH SECURITY_ENFORCED*/];
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
           // WITH SECURITY_ENFORCED
        ];
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 27/08/2021
    * @description HDT_QR_PermissionSet.getCustomPermissionsByUserId() – Get all CustomPermission records assigned to a User
    * @param userId Id of the user to filter the CustomPermissions
    * @return List of extracted CustomPermissions
    */
    public List<CustomPermission> getCustomPermissionsByUserId(Id userId) {

        Set<Id> assigned = new Map<Id, PermissionSet>(
            [
                SELECT Id
                FROM PermissionSet
                WHERE Id IN (
                    SELECT PermissionSetId
                    FROM PermissionSetAssignment
                    WHERE AssigneeId = :userId
                )
                // WITH SECURITY_ENFORCED
            ]).keySet();
    
        return [
                SELECT DeveloperName
                FROM CustomPermission
                WHERE Id IN (
                    SELECT SetupEntityId
                    FROM SetupEntityAccess
                    WHERE SetupEntityType = 'CustomPermission' AND ParentId IN :assigned)
                // WITH SECURITY_ENFORCED
                ];
    }
    
}