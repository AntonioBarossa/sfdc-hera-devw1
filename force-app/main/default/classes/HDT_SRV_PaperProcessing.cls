/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 25/06/2021
* @description HDT_SRV_PaperProcessing.cls
* @history Lorenzo – 25/06/2021 – created class
*/
public with sharing class HDT_SRV_PaperProcessing {
    public static void updateRecords(List<PaperProcessing__c> p){

      

        HDT_UTL_DatabaseService.updateSObject(p);
    }
}
