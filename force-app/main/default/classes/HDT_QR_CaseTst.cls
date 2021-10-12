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

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
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
        Case tCase = [SELECT Id, Status, Type, Phase__c, VulturePracticeReference__c FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];
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
        Order tOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
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
    
        Order tOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];

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
    
        Order tOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];

        List<String> caseIdList = new List<String>();
        caseIdList.add(tCase.Id);    
    
        HDT_QR_Case qrCase = new HDT_QR_Case();
    
        List<Case> testCase = qrCase.getRecordCreatedYesterdayDifferentBy('Pagamenti');
        system.debug('testCase = '+testCase);

        List<Case> testCase1 = qrCase.getRecordCreatedLastWeekEqualsBy('Pagamenti');

    
        System.assertEquals(true, testCase.isEmpty(), 'Case list not empty');

        System.assertNotEquals(false, testCase.isEmpty(), 'value of parameter is not matching');
    
        Test.stopTest();
    
    }
    
    //getRecordByPracticeNumber
    @isTest
    static void getRecordByPracticeNumberTest() {
        Case myCase = [SELECT Id, CaseNumber FROM Case];
        HDT_QR_Case myTestObject = new HDT_QR_Case();
        
        Case result = myTestObject.getRecordByPracticeNumber(myCase.CaseNumber)[0];
        System.assertEquals(myCase.Id, result.Id, 'Case non è il medesimo');
    }
    
}
