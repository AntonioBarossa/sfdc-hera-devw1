public with sharing class HDT_SRV_PaperCommunication {
    public static void updateRecords(List<PaperCommunication__c> p){

      

        HDT_UTL_DatabaseService.updateSObject(p);
    }
}
