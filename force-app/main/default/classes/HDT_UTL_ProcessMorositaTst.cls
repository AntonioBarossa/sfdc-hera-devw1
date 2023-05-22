@isTest
public with sharing class HDT_UTL_ProcessMorositaTst {

    @testSetup
    static void setup(){

        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<ServicePoint__c> servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        servPoint[0].ServicePointCode__c = 'IT001E32452366';
        update servPoint;
        List<Contract> cont = HDT_UTL_DataFactoryTst.createContract(1, false, acc[0].Id);
        cont[0].ServicePoint__c = servPoint[0].Id;
        cont[0].SAPContractCode__c = '3019602323';
        cont[0].Status = 'Attivo';
        insert cont;
        
        List<Contact> contact = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);

        AccountContactRelation acr = [
            SELECT Id, AccountId, ContactId
            FROM AccountContactRelation
            WHERE AccountId = :acc[0].Id
            AND ContactId = :contact[0].Id
        ];
        acr.Roles = 'Titolare';
        update acr;

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 1;
        request.Priority__c = 1;
        request.ProcessType__c = 'Morosita';
        request.Status__c = 'In attesa di lavorazione';
        insert request;
        /*
        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;
    
        for(Integer n=0; n<2; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';

            //PROCESSO,ACCOUNTID,POD,CONTRATTO,UFFICIO_COMPETENTE,DATA_PAGAMENTO
            //Riattivazione Fornitura,0011X00000jcKXUQA2,IT001E00032928,3019602323,HCM,2021-12-23

            if(n>=0 && n<= 3){
                // errore arricchimento dati
                item.Data__c = 'Riattivazione Fornitura|' + acc[0].Id + '|IT001E32452366|3019602323|HCM|2021-12-23';
            } else if(n>3 && n<=6){
                //success
                item.Data__c = 'Riattivazione Fornitura|' + acc[0].Id + '|IT001E00032928|3019602323|HCM|2021-12-23';
            
            } else if(n>6){
                //custom error
                item.Data__c = 'Riattivazione Fornitura|' + acc[0].Id + '|IT001E00032928|3019602323|HCM|2021-12-23';
            }
            itemsList.add(item);
        }
        insert itemsList;
         */
    }


    @isTest
    private static void testDisattivazioniErroreArricchimento(){
        MassiveLoaderRequest__c mainLoader=[SELECT Id FROM MassiveLoaderRequest__c LIMIT 1 ];
        List<Account> acc=[SELECT Id FROM Account LIMIT 1];
        MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
        item.MassiveLoaderRequest__c = mainLoader.Id;
        item.Status__c = 'In attesa di lavorazione';
        item.Data__c = 'Riattivazione Fornitura|' + acc[0].Id + '|IT001E32452366|3019602323|HCM|2021-12-23';
        insert item;
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
    }

    @IsTest
    private static void testDisattivazioniSuccess(){
        MassiveLoaderRequest__c mainLoader=[SELECT Id FROM MassiveLoaderRequest__c LIMIT 1 ];
        List<Account> acc=[SELECT Id FROM Account LIMIT 1];
        MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
        item.MassiveLoaderRequest__c = mainLoader.Id;
        item.Status__c = 'In attesa di lavorazione';
        item.Data__c = 'Riattivazione Fornitura|' + acc[0].Id + '|IT001E00032928|3019602323|HCM|2021-12-23';
        insert item;
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
    }

    @IsTest
    private static void testDisattivazioniCustomError(){
        MassiveLoaderRequest__c mainLoader=[SELECT Id FROM MassiveLoaderRequest__c LIMIT 1 ];
        List<Account> acc=[SELECT Id FROM Account LIMIT 1];
        MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
        item.MassiveLoaderRequest__c = mainLoader.Id;
        item.Status__c = 'In attesa di lavorazione';
        item.Data__c = 'Riattivazione Fornitura|' + acc[0].Id + '|IT001E00032928|3019602323|HCM|2021-12-23';
        insert item;
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
    }

        /*public static void setDataForTest(Integer numRecords){

        Id massiveLoaderRequestId = 'a3d3O000000WuAYQA0';
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

            //PROCESSO,ACCOUNTID,POD,CONTRATTO,UFFICIO_COMPETENTE,DATA_PAGAMENTO
            //Riattivazione Fornitura,0011X00000jcKXUQA2,IT001E00032928,3019602323,HCM,2021-12-23

            if(n>=0 && n<= 10){
                // errore arricchimento dati
                item.Data__c = 'Riattivazione Fornitura|0011X00000owtvoQAA|IT001E32452366|3019602323|HCM|2021-12-23';
            } else if(n>10 && n<=15){
                //success
                item.Data__c = 'Riattivazione Fornitura|0011X00000jcKXUQA2|IT001E00032928|3019602323|HCM|2021-12-23';
            
            } else if(n>15){
                //custom error
                item.Data__c = 'Riattivazione Fornitura|0011X00000jcKXUQA2|IT001E00032928|3019602323|HCM|2021-12-23';
            }
            itemsList.add(item);
        }
        insert itemsList;
    
        MassiveLoaderRequest__c mlr = new MassiveLoaderRequest__c();
        mlr.Id = massiveLoaderRequestId;
        mlr.Status__c = 'In attesa di lavorazione';
        update mlr;
    
    }*/

}