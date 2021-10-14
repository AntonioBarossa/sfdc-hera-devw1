/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 16/06/2021
* @description HDT_QR_Blacklist
* @history Lorenzo – 16/06/2021 – created class
*/
public with sharing class HDT_QR_Blacklist {

    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();

    public static List<BlackList__c> getAllBlacklist(){
        return [Select id,Domain__c,ErrorMessage__c,Note__c from Blacklist__c WITH SECURITY_ENFORCED];
    }

    public static List<BlackList__c> getAllBlacklistEmail(){
        return [Select id,Domain__c,ErrorMessage__c,Note__c from Blacklist__c where domain__c != null WITH SECURITY_ENFORCED];
    }

    public Blacklist__c getBlacklist(String pod) {

        accountSrv.checkReadAccess('id, POD__C, isActive__c');
        String query = 'SELECT id, POD__C, isActive__c  FROM Blacklist__c WHERE POD__C = :pod WITH SECURITY_ENFORCED LIMIT 1 '; 
        Blacklist__c blacklist= new Blacklist__c();
        List<Blacklist__c> blacklistList = Database.query(query);

        if (!blacklistList.isEmpty()) {
            blacklist = blacklistList[0];
        }
        
        return blacklist;
    }

}
