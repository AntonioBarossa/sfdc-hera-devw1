@IsTest
public with sharing class HDT_UTL_CreatePaymentsRequestBodyTst 
{
    private static HDT_UTL_CreatePaymentsRequestBody utlPayments = new HDT_UTL_CreatePaymentsRequestBody();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);    
    }


    @isTest
    static void createBodyRequestTst()
    {
        String result = '';

        List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput> wrpInputList = new List<HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput>();
        HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput wrpParentInput = new HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput();
        wrpParentInput.isParent = true;
        wrpParentInput.isChild = false;
        wrpParentInput.childObjName = null;
        HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput wrpChildInput = new HDT_UTL_CreatePaymentsRequestBody.HDT_UTL_WrapperInput();
        wrpChildInput.isParent = false;
        wrpChildInput.isChild = true;
        wrpChildInput.childObjName = 'childs';
        Map<String, Object> parentMapTest = new Map<String, Object>
        {
            'rds' => 'C-000000',
            'amount' => 32.10,
            'integerAmount' => 12,
            'booleanAmount' => true
        };
        Map<String, Object> childMapTest = new Map<String, Object>
        {
            'dateAmount' => Date.newInstance(2022, 03, 12)
        };
        wrpParentInput.configMapList = new List<Map<String, Object>>{parentMapTest};
        wrpChildInput.configMapList = new List<Map<String, Object>>{childMapTest};
        wrpInputList.add(wrpParentInput);
        wrpInputList.add(wrpChildInput);
        Test.startTest();
            result = utlPayments.createBodyRequest(wrpInputList);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(result), 'body non generato');
    }
    @isTest
    static void handleResponseTst()
    {
        List<Case> caseList = [SELECT Id FROM Case];
        HttpResponse response = new HttpResponse();
        response.setBody('{"status":"success", "correlationId":"asiodj0adjsaosija","timestamp": "1092390809", "data":{"rdsRdo":"1asd0", "tipoAttivita":"","note":"test","numeroBollettino":"test", "importoTotale":"10.12","esito":"OK"}}');
        String process = 'Comunicazione Pagamento';
        String depositMode = '';
        Test.startTest();
            utlPayments.handleResponse(caseList[0].Id, process, depositMode, response);
        Test.stopTest();
        caseList = [SELECT Id, PaperlessCode__c FROM Case];
        System.assertEquals(true, String.isNotBlank(caseList[0].PaperlessCode__c), 'Response non gestita');
    }
    @isTest
    static void handleResponseFailedTst()
    {
        List<Case> caseList = [SELECT Id FROM Case];
        HttpResponse response = new HttpResponse();
        response.setBody('{"status":"failed", "correlationId":"asiodj0adjsaosija","timestamp": "1092390809", "errorDetails":[{"code":"100","message":"error", "additionalInfo": "error"}]}');
        String process = 'Comunicazione Pagamento';
        String depositMode = '';
        Test.startTest();
            utlPayments.handleResponse(caseList[0].Id, process, depositMode, response);
        Test.stopTest();
        caseList = [SELECT Id, TecnicalPhase__c FROM Case];
        System.assertEquals(true, String.isNotBlank(caseList[0].TecnicalPhase__c), 'Response non gestita');
    }
    @IsTest
    static void handleResponseNullTst()
    {
        List<Case> caseList = [SELECT Id FROM Case];
        String process = 'Comunicazione Pagamento';
        String depositMode = '';
        Test.startTest();
            utlPayments.handleResponse(caseList[0].Id, process, depositMode, null);
        Test.stopTest();
        caseList = [SELECT Id, Description FROM Case];
        System.assertEquals(true, String.isNotBlank(caseList[0].Description), 'Response non gestita');
    }
    @IsTest
    static void addBusinessDaysTst()
    {
        Test.startTest();
            Date testDate = utlPayments.addBusinessDay(System.today(), 3);
        Test.stopTest();
        System.assertEquals(true, testDate > System.today(), 'Data non calcolata correttamente');
    }

}
