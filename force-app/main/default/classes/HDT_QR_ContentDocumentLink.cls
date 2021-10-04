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
                WITH SECURITY_ENFORCED
                ORDER BY SystemModstamp DESC];
    }

    /**​
    * @author Keltin Mesonjesi (keltin.mesonjesi@webresults.it)​
    * @date 16/09/2021
    * @description Get record of ContentDocumentLink based on the Linked Entity and ContentDocument Description
    * @param entityId Id of the record Linked to the ContentDocument
    * @param description description that has been set on ContentDocument
    * @return List of extracted Content Document Links
    */
    public List<ContentDocumentLink> getRecordsByEntityAndContentDocumentDescription(String entityId, String description){
        return [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                FROM ContentDocumentLink
                WHERE LinkedEntityId =: entityId
                AND ContentDocument.Description = :description
                WITH SECURITY_ENFORCED
                ORDER BY SystemModstamp DESC];
    }
}