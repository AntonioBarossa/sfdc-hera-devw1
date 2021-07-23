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
        List<Queue__c> queues = [SELECT Id, Name, QueueId__c, Group__c, Agency__c FROM Queue__c WHERE Name LIKE :queryString WITH SECURITY_ENFORCED];
        for(Queue__c queue : queues) {
            results.add(new Map<String,String>{
                'id' => queue.QueueId__c,
                'wrapperId' => queue.Id,
                'name' => queue.Name,
                'workGroup' => queue.Group__c,
                'agency' => queue.Agency__c,
                'icon' => 'standard:queue'
            });
        }

        return results;
    }

    @AuraEnabled
    public static String reassignActivity(String recordId, String assigneeId, String wrapperId, String workGroup, String agency) {
        try {
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
                Id = recordId,
                OwnerId = assigneeId
            );

            if(String.isNotBlank(wrapperId)) {
                activity.WorkGroup__c = workGroup;
                activity.Agency__c = agency;
                activity.Queue__c = wrapperId;
            }

            HDT_UTL_DatabaseService.updateSObject(activity);
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String assignToMe(String recordId) {
        return reassignActivity(recordId, UserInfo.getUserId(), null, null, null);
    }
}