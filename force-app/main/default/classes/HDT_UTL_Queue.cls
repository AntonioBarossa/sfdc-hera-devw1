public with sharing class HDT_UTL_Queue {
    public static void createUnderlyingQueue(List<Queue__c> wrappers) {
        System.enqueueJob(new HDT_QBL_CreateQueuesAndGroups(wrappers, false));
        // Map<String,Group> groupsByName = new Map<String,Group>();
        // for(Group gr : [SELECT Id, Name FROM Group WHERE Type = 'Regular' WITH SECURITY_ENFORCED]) {
        //     groupsByName.put(gr.Name, gr);
        // }
        // Map<String,Group> queuesToCreate = new Map<String,Group>();
        // Map<String,Group> groupsToCreate = new Map<String,Group>();
        // for(Queue__c wrapper : wrappers) {
        //     // IF ASSIGNED WORKGROUP DOES NOT EXIST, CREATE OT
        //     if(!groupsByName.containsKey(wrapper.WorkGroup__c)) {
        //         groupsToCreate.put(wrapper.WorkGroup__c, new Group(
        //             Name = wrapper.WorkGroup__c,
        //             DeveloperName = normalize(wrapper.WorkGroup__c),
        //             Type = 'Regular'
        //         ));
        //     }
        //     // CREATE ACTUAL QUEUE
        //     queuesToCreate.put(wrapper.Name, new Group(
        //         Name = wrapper.Name,
        //         DeveloperName = normalize(wrapper.Name),
        //         Type = 'Queue'
        //     ));
        // }

        // insert queuesToCreate.values();
        // insert groupsToCreate.values();
        // // ADD NEWLY CREATED WORKGROUPS TO PRE-EXISTING ONES
        // groupsByName.putAll(groupsToCreate);

        // List<GroupMember> memberships = new List<GroupMember>();
        // for(Queue__c wrapper : wrappers) {
        //     // ASSIGN WRAPPER TO ACTUAL QUEUE
        //     // wrapper.QueueId__c = queuesToCreate.get(wrapper.Name).Id;

        //     // ASSIGN CREATED WORKGROUPS TO QUEUES
        //     memberships.add(new GroupMember(
        //         GroupId = queuesToCreate.get(wrapper.Name).Id,
        //         UserOrGroupId = groupsByName.get(wrapper.WorkGroup__c).Id
        //     ));
        // }

        // insert memberships;
    }

    private static String normalize(String name) {
        return name
            // .replaceAll('-','_')
            // .replaceAll(' ','_')
            // .replaceAll('/','_')
            // // .replaceAll('\\','_')
            // .replaceAll('.','_')
            // .replaceAll(',','_')
            // .replaceAll(';','_')
            // .replaceAll('à','a')
            // .replaceAll('è','e')
            // .replaceAll('é','e')
            // .replaceAll('ì','i')
            // .replaceAll('ò','o')
            // .replaceAll('ù','u')
            // // .replaceAll('_{2,}','_')
        ;
    }
}