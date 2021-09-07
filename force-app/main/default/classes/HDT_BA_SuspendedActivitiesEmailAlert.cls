public with sharing class HDT_BA_SuspendedActivitiesEmailAlert implements Database.Batchable<wrts_prcgvr__Activity__c>, Database.AllowsCallouts {
    List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
    Map<String, String> usersEmail = new Map<String, String>();
    Map<wrts_prcgvr__Activity__c, User> activityOwner = new Map<wrts_prcgvr__Activity__c, User> ();
    public HDT_BA_SuspendedActivitiesEmailAlert() {
        this.activities = [SELECT Id, Name, SuspensionDueDate__c, Status__c, OwnedByUser__c FROM wrts_prcgvr__Activity__c WHERE SuspensionDueDate__c = TODAY AND Status__c = 'Sospesa' WITH SECURITY_ENFORCED];
        if (this.activities.size() > 0) {
            List<String> userNames = new List<String>();
            for (wrts_prcgvr__Activity__c act : this.activities) {
                userNames.add(act.OwnedByUser__c);
            }
            List<User> users = [SELECT Id, Name, Email FROM User WHERE Name IN :userNames];
            for (User user : users) {
                this.usersEmail.put(user.Name, user.Email);
            }
        }
    }

    public Iterable<wrts_prcgvr__Activity__c> start(Database.BatchableContext bc) {
        return this.activities;
    }

    public void execute(Database.BatchableContext BC, List<wrts_prcgvr__Activity__c> scope) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        OrgWideEmailAddress orgWideAddress = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address' WITH SECURITY_ENFORCED LIMIT 1];
        if (orgWideAddress == null) {
            System.abortJob(BC.getJobId());
        }
        for (wrts_prcgvr__Activity__c activity : scope) {
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            toAddresses.add(this.usersEmail.get(activity.OwnedByUser__c));
            emailMsg.setToAddresses(toAddresses);
            emailMsg.setSubject('Attività sospesa');
            String emailBody = String.format('Gentile utente, <br/> ti segnaliamo che l’attività {0} ha raggiunto la data fine sospensione <br/>', new List<String>{activity.Name});
            emailMsg.setHtmlBody(emailBody);
            emailMsg.setOrgWideEmailAddressId(orgWideAddress.Id);
            emailList.add(emailMsg);
        }
        if(emailList.size() > 0){
            Messaging.sendEmail(emailList);
        }
    }   

    public void finish(Database.BatchableContext bc){
        System.debug('-------- finish batch');
    }
}
