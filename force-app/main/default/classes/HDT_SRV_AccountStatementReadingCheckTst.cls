@isTest
public class HDT_SRV_AccountStatementReadingCheckTst {

    @testSetup
    static void setup() {

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

    }

    @isTest
    static void testCheckLetturaStimata(){

        Case cs = [SELECT Id, ContractCode__c, AccountCode__c, BillNumber__c FROM Case LIMIT 1];

        List<HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput> inputsList = new List<HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput>();
        HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput inputs = new HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput();
        inputs.contractCode = cs.ContractCode__c;
        inputs.customerCode = cs.AccountCode__c;
        inputs.numeroFattura = cs.BillNumber__c;
        inputsList.add(inputs);

        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":[{"contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","secondoLivelloInformativo":[{"letturaStimata":"X","contratto":""}]}]}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AccountStatementReadingCheckTstMock(response));

        List<HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckOutput> resultList = HDT_SRV_AccountStatementReadingCheck.execute(inputsList);

        System.assert(resultList.size() > 0, 'resultList.size() == 0 or resultList == null');

        Test.stopTest();

    }

    @isTest
    static void testCheckLetturaStimataWithoutLettura(){

        Case cs = [SELECT Id, ContractCode__c, AccountCode__c, BillNumber__c FROM Case LIMIT 1];

        List<HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput> inputsList = new List<HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput>();
        HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput inputs = new HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckInput();
        inputs.contractCode = cs.ContractCode__c;
        inputs.customerCode = cs.AccountCode__c;
        inputs.numeroFattura = cs.BillNumber__c;
        inputsList.add(inputs);

        Test.startTest();

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":[{"contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","secondoLivelloInformativo":[{"letturaStimata":"","contratto":"34756347435"}]}]}');
        response.setStatusCode(200);
        response.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AccountStatementReadingCheckTstMock(response));

        List<HDT_SRV_AccountStatementReadingCheck.HDT_WRP_AccountStatementReadingCheckOutput> resultList = HDT_SRV_AccountStatementReadingCheck.execute(inputsList);

        System.assert(resultList.size() > 0, 'resultList.size() == 0 or resultList == null');

        Test.stopTest();

    }
    
    
    //INCREMENTO COVERAGE
    @isTest
    private static void HDT_WRP_ButtonObjDetail_constructor_Test(){
        
        //TESTING
        HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail TestObject1;
        TestObject1 = new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail('labelTemp1', 'nameTemp', true, 'typeTemp', 'parametersTemp');
        
        HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail TestObject2;
        TestObject2 = new HDT_WRP_AccountStatement.HDT_WRP_ButtonObjDetail('labelTemp2', 'nameTemp', true, 'typeTemp', 'parametersTemp', 'accesskeyTemp');
        
        System.assert('labelTemp1'.equalsIgnoreCase(TestObject1.label), 'Not Equals.');
        System.assert('labelTemp2'.equalsIgnoreCase(TestObject2.label), 'Not Equals.');
    }
    
    
    
    
    //HTTP MOCK

    public class HDT_SRV_AccountStatementReadingCheckTstMock implements HttpCalloutMock{
        HttpResponse response;
        HDT_SRV_AccountStatementReadingCheckTstMock(HttpResponse r){
            response = r;
        }
        public HTTPResponse respond(HTTPRequest request) {
            return response; 
        }
    }

}
