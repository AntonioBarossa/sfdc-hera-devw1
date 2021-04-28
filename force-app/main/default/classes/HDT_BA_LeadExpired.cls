public with sharing class HDT_BA_LeadExpired implements Database.Batchable<sObject>, Database.Stateful {

    public List<Lead> leads= new List<Lead>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, CreatedDate, Status, LeadSource FROM Lead Where Status NOT IN (\'Expired\',\'Converted\')';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope){

        Map<String, Integer>  leadValidityMdt = new Map<String,Integer>();
        List<HDT_LeadValidityDate__mdt> validityLead= [Select LeadSource__c, ValidityDay__c from HDT_LeadValidityDate__mdt];
        System.debug(validityLead);


        for(HDT_LeadValidityDate__mdt v: validityLead){
            leadValidityMdt.put(v.LeadSource__c, v.ValidityDay__c.intValue());
        }
        Date todayDate= Date.today();
        for(Lead l: scope){
            if(l.CreatedDate.date().daysBetween(todayDate)>leadValidityMdt.get(l.LeadSource)){
                l.Status= 'Expired';
                leads.add(l);
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        update leads;
    }
}
