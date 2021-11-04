public with sharing class HDT_VFC_ActivityReassignmentMassive {
    public List<wrts_prcgvr__Activity__c> activities{get;private set;}
    public HDT_VFC_ActivityReassignmentMassive(ApexPages.StandardSetController stdSetController){
        // Returns all selected records
        activities = (List<wrts_prcgvr__Activity__c>) stdSetController.getSelected();
    }
}
