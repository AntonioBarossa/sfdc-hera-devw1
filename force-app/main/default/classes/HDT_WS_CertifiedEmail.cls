@RestResource(urlMapping='/CertifiedEmailInboundService/*')
global with sharing class HDT_WS_CertifiedEmail {
    
    @HttpGet
    global static List<Task> doGet() {
        List<Task> pecList = new List<Task>();

        pecList = [SELECT Id, WhoId, Description, PecAddress__c, DoxeePecTemplateCode__c from Task where IsPec__c = True and SentToMulesoft__c = False WITH SECURITY_ENFORCED];

        // Task t = new Task(Description='Test PEC 1', PecAddress__c='test1@example.com', IsPec__c=True, DoxeePecTemplate__c='Ultimo Avviso (26)', SentToMulesoft__c=True);
        // Task tt = new Task(Description='Test PEC 2', PecAddress__c='test2@example.com', IsPec__c=True, DoxeePecTemplate__c='Ultimo Avviso (26)', SentToMulesoft__c=True);

        // pecList.add(t);
        // pecList.add(tt);

        return pecList;
    }
}