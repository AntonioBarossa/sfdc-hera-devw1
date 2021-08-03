public with sharing class HDT_LC_ManualActivityCreator {
    
    @AuraEnabled
    public static void createActivity(String type, Id accountId){
        HDT_UTL_Scarti.getTemplatesMapByName(new Set<String>{'manualiTemplateName'});
        
    }
    
    @AuraEnabled
    public static List<Account> getAccounts(){
        return [SELECT Id, Name FROM Account];
    }
}
