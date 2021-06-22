/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 23/03/2021
 * @description HDT_QR_MassiveLoaderProcess - Class that holds queries for HDT_MassiveLoaderProcess__mdt
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_QR_MassiveLoaderProcess {

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 31/03/2021
    * @description HDT_QR_StaticResource.getAllRecords() – Get MassiveLoaderProcess records
    * @return List of extracted Massive Loader Process
    */
    
    public List<HDT_MassiveLoaderProcess__mdt> getAllRecords() {

        return [SELECT DeveloperName, MasterLabel, Priority__c, IsActive__c 
                FROM HDT_MassiveLoaderProcess__mdt 
                WHERE IsActive__c = true 
                LIMIT 10000];
        
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 31/03/2021
    * @description HDT_QR_StaticResource.getRecordByName() – Get StaticResource record by Name
    * @param name DeveloperName to filter the HDT_MassiveLoaderProcess__mdt query
    * @return List of extracted Static Resources
    */

    public HDT_MassiveLoaderProcess__mdt getRecordByName(String name) {

        return [SELECT DeveloperName, MasterLabel, Priority__c, IsActive__c 
                FROM HDT_MassiveLoaderProcess__mdt 
                WHERE DeveloperName =: name AND IsActive__c = true];

    }
}