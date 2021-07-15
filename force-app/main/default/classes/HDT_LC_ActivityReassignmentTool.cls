public with sharing class HDT_LC_ActivityReassignmentTool {    
    @AuraEnabled
    public static List<Map<String,String>> getAssignees(String queryString) {
        List<Map<String,String>> results = new List<Map<String,String>>();
        queryString = '%' + queryString + '%';
        if(String.isNotBlank(UserInfo.getUserRoleId())) {
            User currentUser = [SELECT Id, UserRole.Name, UserCompany__c FROM User WHERE Id = :UserInfo.getUserId()];
            if(currentUser.UserRole.Name.contains('Supervisore')) {
                // WIP WHERE CLAUSE
                List<User> users = [SELECT Id, Name FROM User WHERE UserCompany__c = :currentUser.UserCompany__c AND Name LIKE :queryString WITH SECURITY_ENFORCED];
                for(User user : users) {
                    results.add(new Map<String,String>{
                        'id' => user.Id,
                        'name' => user.Name,
                        'icon' => 'standard:user'
                    });
                }
            }
        }
        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name LIKE :queryString WITH SECURITY_ENFORCED];
        for(Group queue : queues) {
            results.add(new Map<String,String>{
                'id' => queue.Id,
                'name' => queue.Name,
                'icon' => 'standard:queue'
            });
        }

        return results;
    }

    @AuraEnabled
    public static String reassignActivity(String recordId, String assigneeId) {
        try {
            HDT_UTL_DatabaseService.updateSObject(new wrts_prcgvr__Activity__c(
                Id = recordId,
                OwnerId = assigneeId
            ));
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String assignToMe(String recordId) {
        return reassignActivity(recordId, UserInfo.getUserId());
    }
}