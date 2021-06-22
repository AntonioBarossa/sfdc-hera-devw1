/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 23/03/2021
 * @description HDT_QR_MassiveLoaderRequest - Class that holds queries for MassiveLoaderRequest__c
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_QR_MassiveLoaderRequest {

    HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 31/03/2021
    * @description HDT_QR_MassiveLoaderRequest.getRecordForImport() – Get record of MassiveLoaderRequest ordering by priority
    * @return List of extracted Massive Loader Requests
    */

    public List<MassiveLoaderRequest__c> getRecordForImport() {

        return [SELECT Id, ProcessType__c, Status__c, TotalRequest__c, RequestOK__c, RequestKO__c, Phase__c, Priority__c,
                       (SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility FROM contentdocumentlinks ORDER BY SystemModstamp DESC LIMIT 1) 
                FROM MassiveLoaderRequest__c 
                WHERE Status__c =: constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE 
                AND Phase__c =: constantsUtl.MASSIVLOADER_PHASE_FILENONPROCESSATO
                ORDER BY Priority__c LIMIT 1];
    }
}