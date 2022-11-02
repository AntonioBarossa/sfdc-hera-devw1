@isTest
public class HDT_QR_HerokuPostSalesManagerTst {
    
    @TestSetup
    static void setup(){


        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[1].Name = 'testName2';
        accList[1].CustomerCode__c = '1003616211';
        insert accList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPointList[0].Account__c = accList[0].Id;
        insert servPointList;

        ServicePoint__c sp = [SELECT Id FROM ServicePoint__c LIMIT 1];

        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].ServicePoint__c = sp.Id;
        insert ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].id);
        contractList[0].ServicePoint__c = sp.Id;
        contractList[0].Status = 'Attivo';
        insert contractList;

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, sp.id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].Contract__c  = contractList[0].Id;
        caseList[0].GlobalMigrationKey__c  = 'CF_1-Test';
        insert caseList;

        Case parentCase = [SELECT Id FROM Case LIMIT 1];
        List<Case> caseList2 = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, sp.id, contractList[0].id, ordList[0].id);
        caseList2[0].Type = 'Sospensione Fornitura';
        caseList2[0].ParentId = parentCase.Id;
        insert caseList2;

        List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', 
        '{"name": "Case","label": "Caso","sObjectType": "Case","queryable": true,"fields": ['
        +'{"name": "CreatedDate","label": "DT_RIC_UTENTE"},'
        +'{"name": "CaseNumber","label": "RIF_RICH"},'
        +'{"name": "Type","label": "TIPO_OPERAZIONE"},'
        +'{"name": "Id","label": "RECORD_ID"}'
        +']}'
        ,'Callout_Template.json');
        
        List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates = HDT_UTL_DataFactoryTst.createCalloutTemplate(1, true,'Callout_Prova', 'prova', true, 'Case', 'Flat', contentVersionList[0].ContentDocumentId);
        HDT_UTL_DataFactoryTst.createEndpointRule(1, true, 'Prova');

        AccountContactRelation accConRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id, contactList[0].Id);

        wrts_prcgvr__AsyncJob__c asyncJob = new wrts_prcgvr__AsyncJob__c();
        asyncJob.wrts_prcgvr__JobItem__c = 'test';
        insert asyncJob;

    }

    @IsTest
    static void getCalloutTemplateByCode(){
        
        Test.startTest();

        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        wrts_prcgvr__CalloutTemplate__c callTemp = hpsm.getCalloutTemplateByCode('prova');

        System.assertNotEquals(null, callTemp, 'callTemp = null');
        System.assertEquals('prova', callTemp.wrts_prcgvr__Code__c, 'wrts_prcgvr__Code__c != prova');

        Test.stopTest();
        
    }

    @IsTest
    static void getCaseRecordWithId(){

        Case cs = [SELECT Id FROM Case WHERE Type <> 'Sospensione Fornitura' WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Case returnedCase = hpsm.getCaseRecord(cs.Id);

        System.assertNotEquals(null, returnedCase, 'returnedCase = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getCaseRecordWithCaseNunber(){

        Case cs = [SELECT Id, CaseNumber FROM Case WHERE Type <> 'Sospensione Fornitura' WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Case returnedCase = hpsm.getCaseRecord(cs.CaseNumber);

        System.assertNotEquals(null, returnedCase, 'returnedCase = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getCaseRecordWithGlobalMigrationKey(){

        
        Test.startTest();
        
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Case returnedCase = hpsm.getCaseRecord('CF_1-Test');

        System.assertNotEquals(null, returnedCase, 'returnedCase = null');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetAccountFromSp(){
        
        String pod = 'testServicePointCode';
        
        Test.startTest();
        
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Account returnedAcc = hpsm.getAccountFromSp(pod);

        System.assertNotEquals(null, returnedAcc, 'returnedAcc = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getAccount(){
        
        Test.startTest();
        
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Account returnedAcc = hpsm.getAccount('1003616211'); 

        System.assertNotEquals(null, returnedAcc, 'returnedAcc = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getContact(){

        Account acc = [SELECT Id FROM Account WHERE Name = 'testName2' WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();

        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Contact returnedContact = hpsm.getContact(acc.Id);

        System.assertNotEquals(null, returnedContact, 'returnedContact = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getServicePoint(){

        Test.startTest();

        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        ServicePoint__c returnedSp = hpsm.getServicePoint('testServicePointCode');

        System.assertNotEquals(null, returnedSp, 'returnedSp = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getContract(){

        ServicePoint__c sp = [SELECT Id FROM ServicePoint__c WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();

        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Contract returnedCon = hpsm.getContract(sp.Id);

        System.assertNotEquals(null, returnedCon, 'returnedCon = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getCausalCode(){
        
        Test.startTest();
        
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        HDT_CausalCodeCalculation__mdt causalCodeCalc = hpsm.getCausalCode('Reclami', 'Indennizzo', 'Energia Elettrica');

        System.assertNotEquals(null, causalCodeCalc, 'causalCodeCalc = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getRelatedCase(){

        Case parentCase = [SELECT Id FROM Case WHERE Type <> 'Sospensione Fornitura' WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
    
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        Case returnedCase = hpsm.getRelatedCase(parentCase.Id);

        System.assertNotEquals(null, returnedCase, 'returnedCase = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getAsyncJobByJobItem(){
                
        HDT_QR_HerokuPostSalesManager hpsm = new HDT_QR_HerokuPostSalesManager();
        wrts_prcgvr__AsyncJob__c asyJob = [SELECT Id, wrts_prcgvr__JobItem__c, wrts_prcgvr__Status__c FROM wrts_prcgvr__AsyncJob__c LIMIT 1];
        asyJob.wrts_prcgvr__Status__c = 'Chiusa';
        update asyJob;
        System.debug('input>>>'+asyJob);

        Test.startTest();

        wrts_prcgvr__AsyncJob__c returnedJob = hpsm.getAsyncJobByJobItem(asyJob.wrts_prcgvr__JobItem__c);
        System.debug('output>>>'+returnedJob);
        System.assertNotEquals(null, returnedJob, 'returnedJob = null');

        Test.stopTest();
        
    }
}
