@isTest
public with sharing class HDT_LC_DocumentalPhaseHistoryTst {
    @TestSetup
    private static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }

    @isTest
    private static void getDocumentalPhaseHistoryCase() {
        Test.startTest();
        Case tCase = [SELECT Id, Status FROM Case WHERE Status = 'In Lavorazione' LIMIT 1];
        List<SObject> lstSobj = HDT_LC_DocumentalPhaseHistory.getDocumentalPhaseHistory(tCase.Id, 'Case');
        System.assert(lstSobj.size() > -1, 'getDocumentalPhaseHistoryCase did not work correctly');
        Test.stopTest();
    }

    @isTest
    private static void getDocumentalPhaseHistoryOrder() {
        Test.startTest();
        Order tOrder = [SELECT Id, Status FROM Order LIMIT 1];
        List<SObject> lstSobj = HDT_LC_DocumentalPhaseHistory.getDocumentalPhaseHistory(tOrder.Id, 'Order');
        System.assert(lstSobj.size() > -1, 'getDocumentalPhaseHistoryOrder did not work correctly');
        Test.stopTest();
    }
    
    @isTest
    private static void getParentOrderIdTest() {
        
        //TEST WITH ID
        Order tOrder = [SELECT Id, Status FROM Order LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'tOrder ' + tOrder);
        
        String result = HDT_LC_DocumentalPhaseHistory.getParentOrderId(tOrder.Id);
        System.assert(String.isNotBlank(result), 'getParentOrderId did not work correctly');
        
        //TEST EMPTY
        result = HDT_LC_DocumentalPhaseHistory.getParentOrderId('');
        System.assert(String.isBlank(result), 'getParentOrderId did not work correctly');
        
    }

}
