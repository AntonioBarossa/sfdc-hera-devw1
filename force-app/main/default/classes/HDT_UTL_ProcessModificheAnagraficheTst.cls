@isTest
public with sharing class HDT_UTL_ProcessModificheAnagraficheTst {
    
    /*public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WuVqQAK';
        Set<Id> docId = new Set<Id>();

        delete [
            SELECT Id, Data__c, NextStepData__c, Status__c, StatusDescription__c, MassiveLoaderRequest__c
            FROM MassiveLoaderRequestItem__c
            WHERE MassiveLoaderRequest__c = :massiveLoaderRequestId
        ];

        delete [
            SELECT Id, Type, AccountId, NotPerformedBefore__c, WrittenReceiptRequestDate__c, CustomerRecessDate__c, VulturePracticeReference__c,
                   DistributorNote__c, ServicePoint__c, BillingProfile__c, Contract__c, RecordTypeId, ContactId, CausalCode__c, 
                   Phase__c, Status, CancellationReason__c
            FROM Case
            WHERE CreatedById = '0051X0000055rbNQAQ'
        ];
    
        List<ContentDocumentLink> cdlList = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :massiveLoaderRequestId
        ];

        if(cdlList.size() > 0){
            for(ContentDocumentLink c : cdlList){
                docId.add(c.ContentDocumentId);
            }

            delete cdlList;
            delete [SELECT Id FROM ContentDocument WHERE Id IN :docId];
        }

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        for(Integer n=0; n<numRecords; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = massiveLoaderRequestId;
            item.Status__c = 'In attesa di lavorazione';
            //item.Data__c = 'Variazione Anagrafica Cliente|0011X00000rL7Z6QAK||200010613357|3336560123|3336560123|||||||||||||||||||||||||ADAM|||||||||||||||';//--0011X00000jcKXUQA2
            item.Data__c = '';
            item.Data__c += 'Variazione Anagrafica Cliente|';// PROCESSO
            item.Data__c += '0011X00000rL7Z6QAK|';// ACCOUNTID - 
            item.Data__c += '|';// SOTTOPROCESSO
            item.Data__c += '200010613357|';// CONTO_CONTRATTUALE
            item.Data__c += '3336560123|';// TELEFONO
            item.Data__c += '3336560123|';// CELLULARE
            item.Data__c += '|';// EMAIL
            item.Data__c += '|';// PEC
            item.Data__c += '|';// MARCATURA
            item.Data__c += '|';// FAX
            item.Data__c += '|';// MOD_INVIO_BOLL
            item.Data__c += '|';// MOD_INVIO_FATT_ELET
            item.Data__c += '|';// EMAIL_INVIO_BOLL
            item.Data__c += '|';// PEC_FATT_ELET
            item.Data__c += '|';// PEC_INVIO_BOLL
            item.Data__c += '|';// TIPO_XML
            item.Data__c += '|';// DATA_CONSENSO_PEC
            item.Data__c += '|';// CODICE_UFF_DEST
            item.Data__c += '|';// PRESSO
            item.Data__c += '|';// PEC_SOLLECITO
            item.Data__c += 'false|';// FLAG_SOLLECITO
            item.Data__c += '|';// SPED_COMUNE
            item.Data__c += '|';// SPED_NAZIONE
            item.Data__c += '|';// SPED_LOCALITA
            item.Data__c += '|';// SPED_CAP
            item.Data__c += '|';// SPED_PROVINCIA
            item.Data__c += '|';// SPED_CIVICO
            item.Data__c += '|';// SPED_VIA
            item.Data__c += '|';// SPED_ESTENSIONE_CIV
            item.Data__c += '|';// SPED_INDIRIZZO_COMPLETO
            item.Data__c += 'ADAM|';// NOME
            item.Data__c += '|';// COGNOME
            item.Data__c += '|';// CODICE_FISCALE
            item.Data__c += '|';// PARTIVA_IVA
            item.Data__c += '|';// RES_COMUNE
            item.Data__c += '|';// RES_NAZIONE
            item.Data__c += '|';// RES_LOCALITA
            item.Data__c += '|';// RES_CAP
            item.Data__c += '|';// RES_PROVINCIA
            item.Data__c += '|';// RES_CIVICO
            item.Data__c += '|';// RES_VIA
            item.Data__c += '|';// RES_INDIRIZZO_COMPLETO
            item.Data__c += '|';// IVA_GRUPPO
            item.Data__c += 'true|';// FLAG_IVA
            item.Data__c += '|';// DATA_INIZIO_GIVA
            item.Data__c += '';// DATA_FINE_GIVA
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }*/

}