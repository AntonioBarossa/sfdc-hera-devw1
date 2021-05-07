/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 23/03/2021
 * @description HDT_QR_StaticResource - Class that holds queries for StaticResource
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_QR_StaticResource {
    
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 23/03/2021
    * @description HDT_QR_StaticResource.getRecordByName() – Get StaticResource record by Name
    * @param name Name of the Static Resource to filter the query
    * @return List of extracted Static Resources
    */

    public List<StaticResource> getRecordByName(String name) {

        return [SELECT Id, Name, ContentType, Body, Description, CreatedDate, SystemModStamp 
                FROM StaticResource 
                WHERE Name =: name];

    }
}