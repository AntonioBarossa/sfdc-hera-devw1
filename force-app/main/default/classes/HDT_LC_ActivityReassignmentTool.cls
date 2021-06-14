public with sharing class HDT_LC_ActivityReassignmentTool {
    class DTO {
        String id;
        String name;
        String icon;

        public DTO(String id, String name, String icon) {
            this.id = id;
            this.name = name;
            this.icon = icon;
        }
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getAssignees(String queryString) {
        List<Map<String,String>> results = new List<Map<String,String>>();
        queryString = '%' + queryString + '%';
        if(String.isNotBlank(UserInfo.getUserRoleId())) {
            UserRole role = [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()];
            if(role.Name.contains('Supervisore')) {
                // WIP WHERE CLAUSE
                List<User> users = [SELECT Id, Name FROM User WHERE Name LIKE :queryString WITH SECURITY_ENFORCED];
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
            update new wrts_prcgvr__Activity__c(
                Id = recordId,
                OwnerId = assigneeId
            );
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}