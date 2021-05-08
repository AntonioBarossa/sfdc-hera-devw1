/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 23/03/2021
 * @description HDT_QR_ContentDocumentLink - Class that holds queries for ContentDocumentLink
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_QR_ContentDocumentLink {
    
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 31/03/2021
    * @description HDT_QR_ContentDocumentLink.getRecordsByEntity() – Get record of ContentDocumentLink based on the Linked Entity
    * @param entityId Id of the record Linked to the ContentDocument
    * @return List of extracted Content Document Links
    */

    public List<ContentDocumentLink> getRecordsByEntity(String entityId) {

        return [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                FROM ContentDocumentLink
                WHERE LinkedEntityId =: entityId
                ORDER BY SystemModstamp DESC];
    }
}