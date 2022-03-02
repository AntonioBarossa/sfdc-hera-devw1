@isTest
public with sharing class HDT_UTL_ProcessDisattivazioniTst {

        /*public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WlXDQA0';
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
            item.MassiveLoaderRequest__c = 'a3d3O000000WlXDQA0';
            item.Status__c = 'In attesa di lavorazione';
            if(n>=0 && n<= 10){
                item.Data__c = 'Chiusura Contatore|0011X00000owtvoQAA|IT001E32452366|3019602323|2021-12-23|2021-11-23|2021-10-23|x|errorArrich';
            } else if(n>10 && n<=15){
                switch on n {
                    when 11 {
                        item.Data__c = 'Chiusura Contatore|0011X00000jcKXUQA2|IT001E00032928|3019602323|2021-12-23|2021-11-23|2021-10-23|00000155|success';
                    }	
                    when 12 {
                        item.Data__c = 'Recesso per altri motivi|0011X00000jcKXUQA2|IT001E00032928|3019602323|2021-12-23|2021-11-23|2021-10-23|00000157|success';
                    }
                    when 13 {
                        item.Data__c = 'Recesso per rifiuto voltura|0011X00000jcKXUQA2|IT001E00032928|3019602323|2021-12-23|2021-11-23|2021-10-23|00000160|success';
                    }
                    when 14 {
                        item.Data__c = 'Chiusura Contatore|0011X00000jcKXUQA2|IT001E00032928|3019602323|2021-12-23|2021-11-23|2021-10-23|00000166|success';
                    }
                    when 15 {
                        item.Data__c = 'Chiusura Contatore|0011X00000jcKXUQA2|IT001E00032928|3019602323|2021-12-23|2021-11-23|2021-10-23|00000168|success';
                    }
                }
        
            } else if(n>15){
                item.Data__c = 'Chiusura Contatore|0011X00000jcKXUQA2|IT001E00032928|3019602323|2021-12-23|2021-11-23|x|x|customError';
            }
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = 'a3d3O000000WlXDQA0';
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }

    public static void setDataForTest_VolturaTecnica(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WuVlQAK';
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
            item.Data__c = 'Chiusura Contatore,0011X00000jcKXUQA2,IT001E00032928,3019602323,Ordinaria,No';
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }*/

}