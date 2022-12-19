public with sharing class HDT_BA_OrderQualityCallManagement implements Database.Batchable<sObject>, Database.Stateful{

    private Map<Id,wrts_prcgvr__Activity__c> actMap;
    private Set<Id> childsId;
    private Set<Id> parentsId;

    public HDT_BA_OrderQualityCallManagement(Set<Id> childsId, Set<Id> parentsId, Map<Id,wrts_prcgvr__Activity__c> actToParentOrderMap){
        /* this.query = 'SELECT Id,Skip_Callout__c, OrderNumber, IsVAS__c, Phase__c, PhaseStory__c, Channel__c, CustomerCategory__c, SignatureMethod__c, RecordType.DeveloperName, WizardCompletedDate__c, ParentOrder__c, QualityCall__c, QualityCallUnique__c, Contact__c, PhoneNumber__c, AccountId, AgencyCode__c, ActivatedDate, LoginChannel__c, VASType__c, Account.CompanyOwner__c, isTransition__c, QualityCallStatus__c, HerokuPracticeCode__c, ProcessType__c '
                    + 'FROM Order '
                    + ' WHERE Id IN : childsId OR (ParentOrder__c IN :this.parentsId)'; /* AND QualityCall__c = true AND VasSubtype__c != \'Analisi Consumi\')'; */
        this.childsId = childsId;
        this.parentsId = parentsId;
        this.actMap = actToParentOrderMap;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id,Skip_Callout__c, OrderNumber, IsVAS__c, Phase__c, PhaseStory__c, Channel__c, CustomerCategory__c, SignatureMethod__c, RecordType.DeveloperName, WizardCompletedDate__c, ParentOrder__c, QualityCall__c, QualityCallUnique__c, Contact__c, PhoneNumber__c, AccountId, AgencyCode__c, ActivatedDate, LoginChannel__c, VASType__c, Account.CompanyOwner__c, isTransition__c, QualityCallStatus__c, HerokuPracticeCode__c, ProcessType__c 
            FROM Order 
            WHERE Id IN : childsId OR (ParentOrder__c IN :this.parentsId )
        ]); ///* AND QualityCall__c = true AND VasSubtype__c != 'Analisi Consumi' */
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){
        for (Order o : orders){
            System.debug(LoggingLevel.DEBUG, '@@@@@@OrderNumber ' + o.OrderNumber);
        }
    }

    public void finish(Database.BatchableContext bc){

    }
}
