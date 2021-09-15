/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 25/06/2021
* @description HDT_SRV_PaperCommunication.cls
* @history Lorenzo – 25/06/2021 – created class
*/
public with sharing class HDT_SRV_PaperCommunication {
    public static void insertRecords(List<PaperCommunication__c> p){

      

        HDT_UTL_DatabaseService.insertSObject(p);
    }

    public static void updateRecords(List<PaperCommunication__c> p){

      

        HDT_UTL_DatabaseService.updateSObject(p);
    }
}