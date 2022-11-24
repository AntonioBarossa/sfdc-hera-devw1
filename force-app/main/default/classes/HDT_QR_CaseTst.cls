/**
* @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
* @date 14/07/2021
* @description Test Class for HDT_QR_Case.cls
* @history Fabricio Petkevicius Nunes – 14/07/2021 – Created class
*/

@isTest
public class HDT_QR_CaseTst {

    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList;
        List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
        caseList = HDT_UTL_DataFactoryTst.createCase(2, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        activities[0].Case__c = caseList[0].Id;
        insert activities;
        caseList[0].ParentId = caseList[1].Id;
        update caseList;
        
    }


    @isTest
    static void testgetRecordById() {

        Test.startTest();

        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];

        HDT_QR_Case qrCase = new HDT_QR_Case();

        Case testCase = qrCase.getRecordById(tCase.Id);

    

        System.assertEquals('In Lavorazione', testCase.Status, 'Case Status not populated correctly');


        System.assertNotEquals('Draft', testCase.Status,'value of parameter is not matching');

    


        Test.stopTest();
    
    }

    @isTest
    static void testgetChageNonRegMeterByOrder() {
        Test.startTest();
        //Case tCase = [SELECT Id, Status, Type, Phase__c, VulturePracticeReference__c FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];
        Order tOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];

        //tCase.Type = 'Cambio Contatore Non Registrato';
        //tCase.Phase__c = 'Completata';

        HDT_QR_Case qrCase = new HDT_QR_Case();

        List<Case> testCase = qrCase.getChageNonRegMeterByOrder(tOrder.Id);


        System.assertEquals(true, testCase.isEmpty(), 'Case list not empty');

        System.assertNotEquals(false, testCase.isEmpty(), 'value of parameter is not matching');

   

        Test.stopTest();
    }


    @isTest
    static void testgetParentCaseById() {
    
        Test.startTest();
    
        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];

        HDT_QR_Case qrCase = new HDT_QR_Case();
        
        //EMPTY TEST
        Case emptyCase = qrCase.getParentCaseById(null);
        System.assertEquals(null, emptyCase, 'emptyCase not null');
        
        //REGULAR TEST
        Case testCase = qrCase.getParentCaseById(tCase.Id);
        System.assertEquals('BP/CA - errata categoria', testCase.Type, 'Case type not correct');
    
        System.assertNotEquals('', testCase.Type, 'value of parameter is not matching');
    
        Test.stopTest();
    
    }

    @isTest
    static void testgetRecordsById() {
    
        Test.startTest();
    
        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];

        List<String> caseIdList = new List<String>();
        caseIdList.add(tCase.Id);    
    
        HDT_QR_Case qrCase = new HDT_QR_Case();
    
        List<Case> testCase = qrCase.getRecordsById(caseIdList, 'Status');
        
    
        System.assertEquals('In Lavorazione', testCase[0].Status, 'Case status not correct');
    
        System.assertNotEquals('', testCase[0].Status, 'value of parameter is not matching');
    
        Test.stopTest();
    
    }


    @isTest
    static void testgetRecordCreatedInThePast() {
    
        Test.startTest();
    
        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];

        List<String> caseIdList = new List<String>();
        caseIdList.add(tCase.Id);    
    
        HDT_QR_Case qrCase = new HDT_QR_Case();
    
        List<Case> testCase = qrCase.getRecordCreatedYesterdayDifferentBy('Pagamenti');
        system.debug('testCase = '+testCase);

        List<Case> testCase1;
        testCase1 = qrCase.getRecordCreatedLastWeekEqualsBy('Pagamenti');

    
        System.assertEquals(true, testCase.isEmpty(), 'Case list not empty');

        System.assertNotEquals(false, testCase.isEmpty(), 'value of parameter is not matching');
    
        Test.stopTest();
    
    }
    
    //getRecordByPracticeNumber
    @isTest
    static void getRecordByPracticeNumberTest() {
        List<Case> myCase = [SELECT Id, CaseNumber FROM Case];
        HDT_QR_Case myTestObject = new HDT_QR_Case();
        
        Case result = myTestObject.getRecordByPracticeNumber(myCase[0].CaseNumber)[0];
        System.assertEquals(myCase[0].Id, result.Id, 'Case non è il medesimo');
    }
    
    @IsTest
    static void getRecordByIdCambioUsoTest()
    {
        List<Case> caseList = [SELECT Id FROM Case];
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = new List<Case>{qrCase.getRecordByIdCambioUso(caseList[0].Id)};
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @isTest
    static void getCaseByAccountidTest()
    {
        List<Case> caseList = [SELECT Id, AccountId, Account.Type FROM Case];
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Set<String> accountType = new Set<String>{caseList[0].Account.Type};
        Test.startTest();
            List<Case> result = qrCase.getCaseByAccountid(caseList[0].AccountId,accountType);
        Test.stopTest();
        System.assertEquals(false, !result.isEmpty(), 'Query fallita');
    }
    @IsTest
    static void getChildCasesReclamoTest()
    {
        List<Case> caseList = [SELECT Id, AccountId, Account.Type, ParentId FROM Case WHERE ParentId != NULL];
        String caseId = caseList[0].Id;
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = qrCase.getChildCasesReclamo(caseId,caseList[0].ParentId);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @IsTest
    static void getCaseRelatedTest()
    {
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = new List<Case>{qrCase.getCaseRelated('')};
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @IsTest
    static void getNonReqContrOrderTest()
    {
        List<Case> caseList = [SELECT Id, AccountId, Account.Type, ParentId,Type FROM Case];
        List<Order> ordList = [SELECT Id FROM Order];
        caseList[0].Type = 'Contratto Non Richiesto';
        update caseList;
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = new List<Case>{qrCase.getNonReqContrOrder(ordList[0].id)};
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @IsTest
    static void getNonReqContrCaseTst()
    {
        List<Case> caseList = [SELECT Id, AccountId, Account.Type, ParentId,Type FROM Case];
        caseList[0].Type = 'Contratto Non Richiesto';
        update caseList;
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = new List<Case>{qrCase.getNonReqContrCase('')};
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @IsTest
    static void getServicePointCaseWinBackTst()
    {
        List<Case> caseList = [SELECT Id, AccountId, Account.Type, ParentId,Type FROM Case];
        List<ServicePoint__c> sp = [SELECT id, ServicePointCode__c FROM ServicePoint__c];
        caseList[0].Type = 'Switch Out SII';
        update caseList;
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = qrCase.getServicePointCaseWinBack(sp[0].Id, sp[0].ServicePointCode__c);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @IsTest
    static void getServicePointCaseWinBackOnlyIdTst()
    {
        List<Case> caseList = [SELECT Id, AccountId, Account.Type, ParentId,Type FROM Case];
        List<ServicePoint__c> sp = [SELECT id, ServicePointCode__c FROM ServicePoint__c];
        caseList[0].Type = 'Switch Out SII';
        update caseList;
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = qrCase.getServicePointCaseWinBack(sp[0].Id);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @isTest
    static void getCaseActivitiesTest()
    {
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id, Case__c FROM wrts_prcgvr__Activity__c];
        List<String> caseIds = new List<String>{activities[0].Case__c};
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<wrts_prcgvr__Activity__c> result = qrCase.getCaseActivities(caseIds);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    @IsTest
    static void getChildCase()
    {
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_RichiestaParere'];
        List<Case> caseList = [SELECT Id, AccountId, Account.Type, ParentId FROM Case WHERE ParentId != NULL];
        caseList[0].RecordTypeId = rtList[0].Id;
        update caseList;
        HDT_QR_Case qrCase = new HDT_QR_Case();
        Test.startTest();
            List<Case> result = qrCase.getChildCase(caseList[0].ParentId);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Query fallita');
    }
    
}
