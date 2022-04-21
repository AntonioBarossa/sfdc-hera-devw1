public with sharing class HDT_QBL_CreateQueuesAndGroups implements Queueable {
    private List<Queue__c> wrappers;
    private Boolean finalize;

    public HDT_QBL_CreateQueuesAndGroups(List<Queue__c> wrappers) {
        this.wrappers = wrappers;
        this.finalize = false;
    }

    private HDT_QBL_CreateQueuesAndGroups(List<Queue__c> wrappers, Boolean finalize) {
        this.wrappers = wrappers;
        this.finalize = finalize;
    }

    public void execute(QueueableContext context) {
        if(this.finalize) {
            HDT_UTL_DatabaseService.updateSObject(this.wrappers);
            return;
        }

        Map<String,Group> groupsByName = new Map<String,Group>();
        for(Group gr : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Regular' WITH SECURITY_ENFORCED]) {
            groupsByName.put(getLowerCaseCopy(gr.DeveloperName), gr);
        }
        Map<String,Id> routingConfigsByPriority = new Map<String,Id>();
        for(QueueRoutingConfig config : [SELECT Id, DeveloperName FROM QueueRoutingConfig WITH SECURITY_ENFORCED]) {
            // PERCHE' QUESTA ASSOCIAZIONE FUNZIONI NECESSARIO CHE IL DEVELOPERNAME DELLE ROUTING CONFIG FINISCA PER 1,2,3
            routingConfigsByPriority.put(config.DeveloperName.right(1), config.Id);
        }

        Map<String,Group> queuesToCreate = new Map<String,Group>();
        Map<String,Group> groupsToCreate = new Map<String,Group>();
        String normalizedGroupName;
        for(Queue__c wrapper : wrappers) {
            // IF ASSIGNED WORKGROUP DOES NOT EXIST, CREATE IT
            normalizedGroupName = normalize(wrapper.WorkGroup__c);
            if(!groupsByName.containsKey(getLowerCaseCopy(normalizedGroupName))) {
                groupsToCreate.put(getLowerCaseCopy(normalizedGroupName), new Group(
                    Name = wrapper.WorkGroup__c.left(40),
                    DeveloperName = normalizedGroupName,
                    Type = 'Regular',
                    DoesIncludeBosses = false
                ));
            }
            // CREATE ACTUAL QUEUE
            queuesToCreate.put(getLowerCaseCopy(wrapper.Name), new Group(
                Name = wrapper.Name.left(40),
                DeveloperName = normalize(wrapper.Name),
                Type = 'Queue'
            ));
                
            if(wrapper.Type__c == 'PUSH') {
                queuesToCreate.get(getLowerCaseCopy(wrapper.Name)).QueueRoutingConfigId = wrapper.Priority__c == null ? routingConfigsByPriority.get('3') : routingConfigsByPriority.get(wrapper.Priority__c.left(1));
            }
        }

        HDT_UTL_DatabaseService.insertSObject(queuesToCreate.values());
        HDT_UTL_DatabaseService.insertSObject(groupsToCreate.values());
        // ADD NEWLY CREATED WORKGROUPS TO PRE-EXISTING ONES
        groupsByName.putAll(groupsToCreate);

        List<Queue__c> wrappersToUpdate = new List<Queue__c>();
        List<GroupMember> memberships = new List<GroupMember>();
        List<QueueSobject> queueSobjList = new List<QueueSobject>();
        String queueId;
        for(Queue__c wrapper : wrappers) {
            queueId = queuesToCreate.get(getLowerCaseCopy(wrapper.Name)).Id;
            // SET QUEUES TO ACCEPT wrts_prcgvr__Activity__c RECORDS
            queueSobjList.add(new QueueSObject(
                SobjectType = 'wrts_prcgvr__Activity__c',
                QueueId = queueId
            ));

            // ASSIGN CREATED WORKGROUPS TO QUEUES
            memberships.add(new GroupMember(
                GroupId = queueId,
                UserOrGroupId = groupsByName.get(getLowerCaseCopy(normalize(wrapper.WorkGroup__c))).Id
            ));

            // ASSIGN WRAPPER TO ACTUAL QUEUE
            wrappersToUpdate.add(new Queue__c(
                Id = wrapper.Id,
                QueueId__c = queueId
            ));
        }

        HDT_UTL_DatabaseService.insertSObject(memberships);
        HDT_UTL_DatabaseService.insertSObject(queueSobjList);

        System.enqueueJob(new HDT_QBL_CreateQueuesAndGroups(wrappersToUpdate, true));
    }

    private static String normalize(String name) {
        return name
            .replaceAll('à','a')
            .replaceAll('è','e')
            .replaceAll('é','e')
            .replaceAll('ì','i')
            .replaceAll('ò','o')
            .replaceAll('ù','u')
            // REPLACE ALL NON ALPHANUMERIC CHARS WITH _
            .replaceAll('[^0-9_a-zA-Z]','_')
            // REPLACE MULTIPLE _ WITH A SINGLE ONE
            .replaceAll('_+','_')
            // DELETE LEADING _
            .replaceAll('^_','')
            // DELETE TRAILING _
            .replaceAll('_$','')
        ;
    }

    private static String getLowerCaseCopy(String text) {
        return text.trim().toLowerCase();
    }
}