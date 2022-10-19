/**
* @author Edoardo Zanatta 
* @date 01/10/2022
* @description HDT_QR_HiddenSearchBarPostSales
*/
public with sharing class HDT_QR_HiddenSearchBarPostSales {

    @AuraEnabled
    public static String getCustomMetadataTwo(String processTypeIn, String targetObjectIn){
        String queryTwo = 'SELECT Id, TargetObject__c, ProcessType__c FROM HDT_HiddenSearchBarPostSales__mdt WHERE TargetObject__c =: targetObjectIn AND ProcessType__c =: processTypeIn';
        List<HDT_HiddenSearchBarPostSales__mdt> viewAllList = Database.query(queryTwo);
        System.debug('viewAllList '+viewAllList);
        if(viewAllList != null && viewAllList.size()> 0){
            return 'List is populated';
        }
         return 'List is not populated';
    }



}