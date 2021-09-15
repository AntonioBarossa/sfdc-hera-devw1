public with sharing class HDT_LC_ManualActivityCreator {
    
    @AuraEnabled
    public static String createActivity(String type, Id accountId){
        wrts_prcgvr__Activity__c newAct = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateName(accountId, type);
        if(newAct != null){
            HDT_UTL_DatabaseService.insertSObject(newAct);
            return newAct.Id;
        }
        else return null;
    }
    
    @AuraEnabled
    public static List<Account> getAccounts(){
        return new HDT_QR_Account().getAllAccounts();
    }
}