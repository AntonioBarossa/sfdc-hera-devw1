@isTest
public class HDT_LC_AccountStatementPickerTst {
    
    @TestSetup
    static void setup(){

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

        HDT_UTL_DataFactoryTst.pClickCasePhase();

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO;
        String rtId = constantsUtl.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Documentazione', 'Bozza', rtId, rtName,'A','','','');

        List<DocumentSelected__c> documents = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id,billingProfileList[0].ContractAccountCode__c);
        
    }

    @isTest
    static void testGetDocumentSelected(){

        Case cs = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();

        Map<String, Object> valuesMap = new Map<String, Object>();

        for(Object obj : (List<Object>)JSON.deserializeUntyped(HDT_LC_AccountStatementPicker.getDocumentSelected(cs.Id))){
            Map<String, Object> data = (Map<String, Object>)obj;
            valuesMap.putAll(data);
         }

        System.debug('Document Selected: ' + valuesMap);

        System.assert(valuesMap != null, 'Si è verificato un errore in fase di get del documento');
        System.assert(valuesMap.get('attributes') != null, 'Si è verificato un errore in fase di get del documento');

        Test.stopTest();

    }

    @isTest
    static void testSubmitAndManage(){

        Test.setMock(HttpCalloutMock.class, new HDT_LC_AccountStatementPickerTstMock());
        
        Test.startTest();

        String params = '{"codCli":"1002647967","codContoContratto":"200008284449","fromDate":"01/01/2019","toDate":"31/12/2019"}';

        Map<String, Object> valuesMap = new Map<String, Object>();

        for(Object obj : (List<Object>)JSON.deserializeUntyped(HDT_LC_AccountStatementPicker.getStatements(params))){
            Map<String, Object> data = (Map<String, Object>)obj;
            valuesMap.putAll(data);
         }

        System.debug('ValuesMap: ' +  JSON.serialize(valuesMap));

        System.assert(valuesMap != null, 'Si è verificato un errore in fase di get');
        System.assert(valuesMap.get('contoContrattuale') != null, 'Si è verificato un errore in fase di get');

        Test.stopTest();
    }

    public class HDT_LC_AccountStatementPickerTstMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success","correlationId":"2ded9f00-0c05-11ec-ae39-06cc66aef362","timestamp":"2021-09-02T17:48:13","prestazione":{"codCli":"1002647967","codContoContratto":"200008284449","posizioni":[{"xblnr":"500002727014","socEmittente":"1070","tipoDoc":"4C","totFattura":"32.22","residuo":"-32.22","totPagare":"-32.22","bmItemDt":"31/08/2021","bmEndDt":"20/09/2021","payment":"CLICKPAY","restituzioneCanoneRai":"0.0"},{"xblnr":"500002727014","socEmittente":"1070","tipoDoc":"4C","totFattura":"-32.0","residuo":"32.0","totPagare":"32.0","bmItemDt":"31/08/2021","bmEndDt":"20/10/2021","payment":"CLICKPAY","restituzioneCanoneRai":"-10.00"}]}}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }
}
