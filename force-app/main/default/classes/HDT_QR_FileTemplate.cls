/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 23/03/2021
 * @description HDT_QR_FileTemplate - Class that holds queries for FileTemplate__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_QR_FileTemplate {
    
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 31/03/2021
    * @description HDT_QR_FileTemplate.getRecordByTemplateName() – Get FileTemplate an columns based on the template api name
    * @param templateName The name of the file template to filter the query
    * @return the retrieved records based on the filter
    */

    public List<FileTemplate__c> getRecordByTemplateName(String templateName) {

        return [SELECT Id, Name, HeadLineIndex__c, FileTemplateName__c, FileTemplateApiName__c, FileDelimiter__c, FileExtension__c, FileType__c, 
                       (SELECT Id, Name, FileTemplate__c, HeaderApiName__c, HeaderName__c, Index__c, Mandatory__c, DataType__c, ValidationRegex__c, SobjectType__c FROM FileTemplateColumns__r) 
                FROM FileTemplate__c WHERE FileTemplateApiName__c =: templateName];
    }
}