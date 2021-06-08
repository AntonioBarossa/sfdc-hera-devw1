/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 23/03/2021
 * @description HDT_QR_ContentVersion - Class that holds queries for ContentVesion
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_QR_ContentVersion {
    
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 31/03/2021
    * @description HDT_QR_StaticResource.getRecirdById() – Get ContentVersion record by Id
    * @param contentVersionId Id to filter the ContentVersion query
    * @return Extracted ContentVersion
    */

    public ContentVersion getRecordById(String contentVersionId) {

        return [SELECT Id, ContentDocumentId, VersionData, Title, FileType  
                FROM ContentVersion 
                WHERE Id =: contentVersionId];
    }

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 31/03/2021
    * @description HDT_QR_StaticResource.getRecordByDocumentId() – Get latest ContentVersion record for parent ContentDocument
    * @param documentId Id of the parent ContentDocument
    * @return Created string query
    */

    public String recordByDocumentIdQueryString(String documentId) {

        return 'SELECT Id, ContentDocumentId, VersionData, Title, FileType  ' +
                'FROM ContentVersion ' +
                'WHERE ContentDocumentId = \'' + documentId + '\' ' +
                'AND IsLatest = true ' +
                'LIMIT 1';
    }
}