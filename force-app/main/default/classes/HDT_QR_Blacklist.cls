public with sharing class HDT_QR_Blacklist {
    public static List<BlackList__c> getAllBlacklist(){
        return [Select id,Domain__c,ErrorMessage__c,Note__c from Blacklist__c];
    }
}
