public with sharing class HDT_LC_ContactSelection {

    @AuraEnabled(cacheable = false)
    public static String getListRecords(String accountId){
        String recordListString;
        try{
            System.debug('HDT_LC_ContactSelection: accountId: ' + accountId);

            List<List<sObject>> recordList = new List<List<sObject>>();

            List<AccountContactRelation> relationList = [SELECT ContactId FROM AccountContactRelation WHERE AccountId = :accountId WITH SECURITY_ENFORCED];
            List<Id> contactIds = new List<Id>();
            for (AccountContactRelation acr : relationList) {
                contactIds.add(acr.ContactId);
            }

            List<Contact> contactsList = [SELECT Id, Name, Phone, MobilePhone, Email, Fax, PEC__c from Contact WHERE ID IN :contactIds WITH SECURITY_ENFORCED];

            recordList.add(contactsList);

            if(recordList != null){
                recordListString = JSON.serialize(recordList);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return recordListString;
    }
}