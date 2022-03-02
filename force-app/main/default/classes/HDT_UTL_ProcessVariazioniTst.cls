@isTest
public with sharing class HDT_UTL_ProcessVariazioniTst {

     /*public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WwZOQA0';
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
            item.Data__c = '';
            item.Data__c += 'Variazione indirizzo di fornitura|';// PROCESSO
            item.Data__c += '0011X00000pJuhFQAS|';// ACCOUNTID
            item.Data__c += '|';// SOTTOPROCESSO
            item.Data__c += '15750000008418|';// POD
            item.Data__c += '3019671256|';// CONTRATTO
            item.Data__c += '|';// ELEMENTI_DETTAGLIO
            item.Data__c += '|';// SERVIZIO_ENERGIA
            item.Data__c += '|';// DATA_VARIAZIONE
            item.Data__c += '|';// MATRICOLA
            item.Data__c += '|';// RIF_VOLTURA
            item.Data__c += '|';// NOTE_DL
            item.Data__c += '|';// CORRETTORE
            item.Data__c += '|';// DATA_LETTURA
            item.Data__c += '|';// DATA_VAR_RESIDENZA
            item.Data__c += '|';// RESIDENTE
            item.Data__c += 'VIA RANUCCI RENATO 1 , FERRARA FE, 44100 ITALIA|';// INDIRIZZO_FORN
            item.Data__c += 'FERRARA|';// COMUNE
            item.Data__c += 'ITALIA|';// NAZIONE
            item.Data__c += '|';// LOCALITA
            item.Data__c += '44100|';// CAP
            item.Data__c += 'FE|';// PROVINCIA
            item.Data__c += 'VIA RANUCCI RENATO|';// VIA
            item.Data__c += '1|';// CIVICO
            item.Data__c += '|';// ESTENSIONE_CIVICO
            item.Data__c += '004-Uso tecnologico|';// CATEGORIA_USO
            item.Data__c += '|';// TIPO_FORNITURA
            item.Data__c += '|';// TIPO_IMPIANTO
            item.Data__c += '|';// IMPOSTE
            item.Data__c += '|';// DATA_DECORRENZA
            item.Data__c += ''; // IVA
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }*/   

}