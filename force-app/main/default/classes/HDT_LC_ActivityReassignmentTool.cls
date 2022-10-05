/**
 * @author Lorenzo Rollo (lorenzo.rollo@everis.com)
 * @date 14/06/2021
 * @description HDT_LC_ActivityReassignmentTool
 * @history Name – Date – Description
 */

public with sharing class HDT_LC_ActivityReassignmentTool {
    private static Set<String> dynamicWorkGroupChannels = new Set<String> {
        'Assistente web',
        'Back office',
        'Consip',
        'PA',
        'Protocollo',
        'ServiziSociali',
        'Staff',
        'Supporto agenzie',
        'Supporto GDA',
        'Back office Vendita',
        'Back office Teleselling'
    };


    @AuraEnabled
    public static List<Map<String,String>> getWorkGroups(String queryString) {
        queryString = '%' + queryString + '%';
        List<Map<String,String>> results = new List<Map<String,String>>();

        for(AggregateResult result : [SELECT WorkGroup__c, Agency2__c FROM Queue__c WHERE WorkGroup__c LIKE :queryString WITH SECURITY_ENFORCED GROUP BY WorkGroup__c, Agency2__c]) {
            results.add(new Map<String,String>{
                'name' => (String) result.get('WorkGroup__c'),
                'agency' => (String) result.get('Agency2__c'),
                'displayname' => (String) result.get('WorkGroup__c') + ' - ' +(String) result.get('Agency2__c')
            });
        }

        return results;
    }

    @AuraEnabled
    public static User getCurrentUser() {
        return [SELECT Id, UserCompany__c, LoginChannel__c, CreatorGroup__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static Boolean isDynamicWorkGroup(String loginChannel) {
        return dynamicWorkGroupChannels.contains(loginChannel);
    }

    @AuraEnabled
    public static List<Map<String,String>> getAssignees(String queryString) {
        List<Map<String,String>> results = new List<Map<String,String>>();
        queryString = '%' + queryString + '%';
        User currentUser = getCurrentUser();
        List<PermissionSetAssignment> assignments = new HDT_QR_PermissionSet().getPermissionSetAssignmentByName('HDT_OmniSupervisor', currentUser.Id);
        List<PermissionSetAssignment> assignToUser = new HDT_QR_PermissionSet().getPermissionSetAssignmentByName('HDT_AssignToUser', currentUser.Id);
        if(!assignments.isEmpty() || !assignToUser.isEmpty()) {
            for(User user : [SELECT Id, Name, LoginChannel__c, CreatorGroup__c, UserCompany__c FROM User WHERE UserCompany__c = :currentUser.UserCompany__c AND Name LIKE :queryString WITH SECURITY_ENFORCED]) {
                results.add(new Map<String,String>{
                    'id' => user.Id,
                    'name' => user.Name,
                    'loginChannel' => user.LoginChannel__c,
                    // 'workGroup' => user.CreatorGroup__c,
                    'workGroup' => null,
                    'agency' => user.UserCompany__c,
                    'icon' => 'standard:user'
                });
            }
        }

        for(Queue__c queue : [SELECT Id, Name, QueueId__c, WorkGroup__c, Agency2__c FROM Queue__c WHERE Name LIKE :queryString WITH SECURITY_ENFORCED]) {
            results.add(new Map<String,String>{
                'id' => queue.QueueId__c,
                'wrapperId' => queue.Id,
                'name' => queue.Name,
                'workGroup' => queue.WorkGroup__c,
                'agency' => queue.Agency2__c,
                'icon' => 'standard:queue'
            });
        }

        return results;
    }

    @AuraEnabled
    public static String reassignActivity(List<String> idList, String assigneeId, String wrapperId, String workGroup, String agency) {
        try {
            List<wrts_prcgvr__Activity__c> activitiesToUpdate = new List<wrts_prcgvr__Activity__c>();
            List<wrts_prcgvr__Activity__c> parentActivitiesToUpdate = new List<wrts_prcgvr__Activity__c>();
            Set<Id> parentActivitiesIds = new Set<Id>();

            for(wrts_prcgvr__Activity__c activity : [SELECT Id, Name, Type__c, ParentActivity__c, ParentActivity__r.Order__r.Agency__c FROM wrts_prcgvr__Activity__c WHERE Id IN :idList WITH SECURITY_ENFORCED]) {
                if(activity.Type__c == 'Gestione Agenzia' && activity.ParentActivity__c != null) {
                    if(
                        activity.ParentActivity__r.Order__c != null &&
                        activity.ParentActivity__r.Order__r.Agency__c != null &&
                        activity.ParentActivity__r.Order__r.Agency__c != agency
                    ) {
                        return 'L\'Attività ' + activity.Name +' deve essere assegnata all\'Agenzia ' + activity.ParentActivity__r.Order__r.Agency__c;
                    }
                    if(!parentActivitiesIds.contains(activity.ParentActivity__c)) {
                        parentActivitiesIds.add(activity.ParentActivity__c);
                        parentActivitiesToUpdate.add(new wrts_prcgvr__Activity__c(
                            Id = activity.ParentActivity__c,
                            wrts_prcgvr__Status__c = 'Aperta'
                        ));
                    }
                }

                activity = new wrts_prcgvr__Activity__c(
                    Id = activity.Id,
                    AssigneeType__c = 'Utente',
                    OwnerId = assigneeId,
                    WorkGroup__c = workGroup,
                    Agency__c = agency,
                    ManuallyReassigned__c = true,
                    Queue__c = null,
                    AssignedToQueueDate__c = Date.today()
                );

                if(String.isNotBlank(wrapperId)) {
                    activity.AssigneeType__c = 'Coda';
                    activity.Queue__c = wrapperId;
                    activity.AssignedToQueueDate__c = Date.today();
                }

                activitiesToUpdate.add(activity);
            }

            HDT_UTL_DatabaseService.updateSObject(activitiesToUpdate);
            HDT_UTL_DatabaseService.updateSObject(parentActivitiesToUpdate);

            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String assignToMe(List<String> idList) {
        User currentUser = getCurrentUser();

        return reassignActivity(idList, UserInfo.getUserId(), null, currentUser.CreatorGroup__c, currentUser.UserCompany__c);
    }

    @AuraEnabled(cacheable = true)
    public static Boolean refreshPage(String recordId) {
        Boolean response = false;
        if (String.isNotBlank(recordId)){
            List<String> typeToRefresh = new List<String>{'APPROVAZIONE BONUS COMMERCIALE'};
            for (wrts_prcgvr__Activity__c act : [SELECT Type__c FROM wrts_prcgvr__Activity__c WHERE Id = :recordId WITH SECURITY_ENFORCED]){
                if (String.isNotEmpty(act.Type__c) && typeToRefresh.contains(act.Type__c.toUpperCase())){
                    response = true;
                }
            }
        }
        return response;
    }
}