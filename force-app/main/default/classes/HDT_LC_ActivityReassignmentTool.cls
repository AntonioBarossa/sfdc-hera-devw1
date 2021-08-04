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
            wrts_prcgvr__Activity__c activity = [SELECT Id, Type__c, ParentActivity__c, ParentActivity__r.Order__r.Agency__c FROM wrts_prcgvr__Activity__c WHERE Id = : recordId];
            if(activity.Type__c == 'Gestione Agenzia' && activity.ParentActivity__c != null) {
                if(
                    activity.ParentActivity__r.Order__c != null &&
                    activity.ParentActivity__r.Order__r.Agency__c != null &&
                    activity.ParentActivity__r.Order__r.Agency__c != agency
                ) {
                    return 'La coda selezionata non è gestita dall\'Agenzia corretta.';
                }
                HDT_UTL_DatabaseService.updateSObject(new wrts_prcgvr__Activity__c(
                    Id = activity.ParentActivity__c,
                    wrts_prcgvr__Status__c = 'Aperta'
                ));
            }

            activity = new wrts_prcgvr__Activity__c(
                Id = recordId,
                AssigneeType__c = 'Utente',
                OwnerId = assigneeId
            );

            if(String.isNotBlank(wrapperId)) {
                activity.AssigneeType__c = 'Coda';
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