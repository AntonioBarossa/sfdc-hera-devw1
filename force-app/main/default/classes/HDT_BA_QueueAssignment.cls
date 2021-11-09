public inherited sharing class HDT_BA_QueueAssignment implements Database.Batchable<SObject>{

    public List<Account> accts= new List<Account>();

    public HDT_BA_QueueAssignment(List<Account> accounts){
        this.accts = accounts;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> accountIds= new Set<Id>();
        System.debug(this.accts);
        for (Account ac : this.accts) {
            accountIds.add(ac.Id);
        }
        String query = 'SELECT Id, Name,  DeveloperName, PortalAccountId, PortalRole FROM UserRole WHERE PortalAccountId IN :accountIds AND PortalRole =\'Executive\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<UserRole> scope) {
        Set<Id> roleIds= new Set<Id>();
        Set<Id> groupIds= new Set<Id>();
        Map<String,String> usRoles= new Map<String,String>();
        Map<String,String> grIds= new Map<String,String>();
        Map<String,String> accGroup= new Map<String,String>();
        Map<String,String> accRoles= new Map<String,String>();
        Map<String,String> accGroupMembers= new Map<String,String>();
        Map<String,String> queueRole= new Map<String,String>();
        List<Group> queuesToCreate= new List<Group>();
        List<QueuesObject> queues= new List<QueuesObject>();        
        List<GroupMember> gMembers= new List<GroupMember>();

        for (UserRole u: scope){
            roleIds.add(u.Id);
            usRoles.put(String.valueOf(u.Id),String.valueOf(u.PortalAccountId));
            accRoles.put(String.valueOf(u.PortalAccountId),String.valueOf(u.Id));
        }

        List<Group> groups= [SELECT Id, DeveloperName, RelatedId, Type from Group WHERE RelatedId IN :roleIds AND Type ='RoleAndSubordinates'];
        for (Group gr: groups){
            groupIds.add(gr.Id);
            grIds.put(String.valueOf(gr.Id),String.valueOf(gr.RelatedId));
            accGroup.put(usRoles.get(gr.RelatedId), String.valueOf(gr.Id));
        }
        if(!groups.isEmpty()){
            List<GroupMember> groupMembers= [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN :groupIds];
            for(GroupMember gm: groupMembers){
                accGroupMembers.put(usRoles.get(grIds.get(String.valueOf(gm.UserOrGroupId))),String.valueOf(gm.Id));
            }
        }
        String nameAccount='';
        String name='';
        List<String> nm= new List<String>();
        for(Account a: this.accts){
            if(!accGroupMembers.containsKey(String.valueOf(a.Id)) && accRoles.containsKey(String.valueOf(a.Id))){
                nameAccount= a.Name.replace('Agenzia','');
                nm =nameAccount.split(' ');
                name='';
                for(String s: nm){
                    name+= s.toLowercase().capitalize();
                }
                name= 'HDT_QUE_' + name;
                Group newQueue=new Group(Name= name, Type='QUEUE');
                queuesToCreate.add(newQueue);
                queueRole.put(name,accGroup.get(String.valueOf(a.Id)));
            }
        }
        insert queuesToCreate;

        for(Group g: queuesToCreate){
            QueuesObject qLead= new QueuesObject (SobjectType='Lead',QueueId= g.id);
            QueuesObject qActivity= new QueuesObject (SobjectType='wrts_prcgvr__Activity__c',QueueId= g.id);
            queues.add(qLead);
            queues.add(qActivity);
            GroupMember gm = new GroupMember();
            gm.GroupId= g.Id;
            gm.UserOrGroupId= queueRole.get(g.Name);
            gMembers.add(gm);
        }
        insert queues;
        insert gMembers;

    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.abortJob(a.id);
        List<CronTrigger> objList = [SELECT Id, CronJobDetail.Name, CronJobDetail.Id,State FROM CronTrigger where CronJobDetail.Name like '%PartnerQueues%' ORDER BY CreatedDate DESC];
        System.abortJob(objList[0].Id);
    }

}