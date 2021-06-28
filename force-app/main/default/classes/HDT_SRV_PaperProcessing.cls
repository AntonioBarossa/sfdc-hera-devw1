public with sharing class HDT_SRV_PaperProcessing {
    public static void updateRecords(List<PaperProcessing__c> p){

      

        HDT_UTL_DatabaseService.updateSObject(p);
    }
}
