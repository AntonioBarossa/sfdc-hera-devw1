@isTest
public with sharing class HDT_UTL_ProcessCaricamentoInizDgrerTst {
    @testSetup
    static void setup(){

        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<ServicePoint__c> servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> cont = HDT_UTL_DataFactoryTst.createContract(1, false, acc[0].Id);
        cont[0].ServicePoint__c = servPoint[0].Id;
        cont[0].SAPContractCode__c = '3019602323';
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
        request.ProcessType__c = 'CaricamentoIniziativaDgrer';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;

        
        item = new MassiveLoaderRequestItem__c();
        item.MassiveLoaderRequest__c = request.Id;
        item.Status__c = 'In attesa di lavorazione';
        item.Data__c = '3019602323|TEST CLASS';
        itemsList.add(item);
        insert itemsList;

    }

    @isTest
    public static void testDgrer(){
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
    }

      

}