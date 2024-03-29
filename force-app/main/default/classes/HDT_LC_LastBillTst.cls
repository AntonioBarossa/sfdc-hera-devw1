@isTest
public class HDT_LC_LastBillTst {
    
    
    //TEST SETUP
    @testSetup
    static void setup() {
        KpiTracking__c kpi = new KpiTracking__c();
        kpi.LastBillAmount__c = 10;
        kpi.LastBillNumber__c = '101';
        kpi.LastBillExpirationDate__c = Date.today();
        kpi.LastBillPaymentStatus__c = 'PAGATA';
        kpi.LastBillCommodity__c = '{"Energia elettrica":"true"}';
        kpi.LastBillLastUpdate__c = Date.today();
        insert kpi;
    }
    
    
    //getData
    @isTest
    static void getDataTest(){
        
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('outcome', 'OK');
        mapp.put('amount', '10.00');
        mapp.put('billNumber', '101');
        mapp.put('expiredDate', String.valueOf(System.now().format('dd/MM/yyyy')));
        mapp.put('billStatus', 'PAGATA');
        mapp.put('commodity', '{"Energia elettrica":"true"}');
        mapp.put('callws', 'false');
        String expectedResult = JSON.serialize(mapp);

        KpiTracking__c kpi = [SELECT Id FROM KpiTracking__c LIMIT 1];
        String result = HDT_LC_LastBill.getData('accountCode', 'mode', kpi.Id);
        
        System.assertEquals(expectedResult, result, 'getData did not work correctly');
		System.assertNotEquals(null, result,'getData did not work correctly');

    }
    
    
    //updateKpiTracking
    @isTest
    static void updateKpiTrackingTest(){

        Map<String,String> mapping = new Map<String,String>();
        mapping.put('commodity', '{"Energia elettrica":"true"}');
        mapping.put('billStatus', 'PAGATA');
        mapping.put('expiredDate', String.valueOf(System.now().format('dd/MM/yyyy')));
        mapping.put('billNumber', '101');
        mapping.put('amount', '10');

        String serializedInput = JSON.serialize(mapping);

        KpiTracking__c kpi = [SELECT Id FROM KpiTracking__c LIMIT 1];
        String result = HDT_LC_LastBill.updateKpiTracking(serializedInput, kpi.Id);
        
        System.assertEquals('OK', result, 'updateKpiTracking did not work correctly');
		System.assertNotEquals(null, result,'updateKpiTracking did not work correctly');
        
    }
    
    
    @isTest
    public static void testWebService() {

        KpiTracking__c kpi = [SELECT Id FROM KpiTracking__c LIMIT 1];

        HDT_LC_LastBill controller = new HDT_LC_LastBill();
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)HDT_LC_LastBill.startRequest('accountCode', 'mode', kpi.Id);
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1, 'getRequests did not work correctly');
        //system.assert(requests.get(controller.requestLabel) != null);
        
        
        //PREPARAZIONE RESPONSE BODY
        Map<String, Object> mySecondoLivelloMap = new Map<String, Object>();
        mySecondoLivelloMap.put('settoreMerceologico', 'Gas');
        
        
        List<Object> secondoLivelloList = new List<Object>();
        secondoLivelloList.add(mySecondoLivelloMap);
        
        Map<String, Object> myPrimoLivelloMap = new Map<String, Object>();
        myPrimoLivelloMap.put('secondoLivelloInformativo', secondoLivelloList);
        myPrimoLivelloMap.put('residuo', '10.5');
        myPrimoLivelloMap.put('importo', '21.0');
        myPrimoLivelloMap.put('numeroFattura', '10203040');
        myPrimoLivelloMap.put('dataScadenza', JSON.serialize(Date.today().addDays(10)));
        
        List<Object> myData = new List<Object>{myPrimoLivelloMap};
        
        //BODY MAP
        Map<String, Object> bodyResponse = new Map<String, Object>();
        bodyResponse.put('data', myData);
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody(JSON.serialize(bodyResponse));//RESPONSE DEVE ESSERE Map<String, Object>
        
        // Set the fake response for the continuation
        Test.setContinuationResponse('Continuation-1', response);
        
        // Invoke callback method
        String result = HDT_LC_LastBill.processResponse(new List<String>{'Continuation-1'}, null);
        Map<String,String> resultDes = (Map<String,String>) JSON.deserialize(result, Map<String,String>.class);
        
        String outcome = (String) resultDes.get('outcome');
        String importo = (String) resultDes.get('amount');
        
        // result is the return value of the callback
        System.assert('OK'.equalsIgnoreCase(outcome), 'Outcome Non OK');
        System.assert('21.0'.equalsIgnoreCase(importo), 'Importo non 21.0');
        
    }
    
    
    
    //getLastBillDataFromSap
    @isTest
    private static void getLastBillDataFromSapTest(){
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        //WEBSERVICE MOCKS
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TESTING
        Test.startTest();
        String result = (String) HDT_LC_LastBill.getLastBillDataFromSap(accList[0].CustomerCode__c);
        Test.stopTest();
        
        //ASSERTS
        System.debug('Result: ' + result);
        System.assert(String.isNotBlank(result), 'Result è stringa vuota.');
        
    }
    
    
    
    //WEBSERVICE MOCKS
    public class myWebServiceMock implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            HttpResponse response = new HttpResponse();
            
            //SETTING UP RESPONSE BODY
            Map<String, Object> singleObjMap = new Map<String, Object>();
            singleObjMap.put('numeroFattura', 'FakeBillNumber');
            singleObjMap.put('dataEmissione', '2021/09/10');
            singleObjMap.put('numeroFattura', 'Acantho S.p.A');
            
            
            List<Object> dataObj = new List<Object>();
            dataObj.add(singleObjMap);
            
            Map<String, Object> bodyResp = new Map<String, Object>();
            bodyResp.put('data', dataObj);
            
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(bodyResp));
            response.setStatusCode(200);
            response.setStatus('OK');
            
            return response;
        }
    }
    
}