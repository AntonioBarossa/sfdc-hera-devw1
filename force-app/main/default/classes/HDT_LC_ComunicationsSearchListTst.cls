@isTest
public class HDT_LC_ComunicationsSearchListTst {

    @testSetup
    static void setup() {
    
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

    }

    @isTest
    static void getWsData(){
        
        String wrapperObj = '{"billingProfile":"123","documentCategory":"Solleciti","customerAccount":"200005834844","startDate":"2019-07-17","endDate":"2019-07-18"}';
        Test.setMock(HttpCalloutMock.class, new HDT_LC_ComunicationsSearchListTstMock());

        Test.startTest();
        
        // Object obj = HDT_LC_ComunicationsSearchList.getWsData(wrapperObj);

        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj obj = (HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj) JSON.deserialize((String)HDT_LC_ComunicationsSearchList.getWsData(wrapperObj), HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj.class);
        
        System.assertEquals(true, obj.success, 'Si è verificato un errore in fase di chiamata al WS');
        String expectedBody = '{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": {}}';
        System.assertEquals(expectedBody, obj.body, 'Si è verificato un errore in fase di ricezione del body della response');

        Test.stopTest();
        
    }

    @isTest
    static void getWsDataBollette(){
        
        String wrapperObj = '{"billingProfile":"123","documentCategory":"Bollette","customerAccount":"200005834844","startDate":"2019-07-17","endDate":"2019-07-18"}';
        Test.setMock(HttpCalloutMock.class, new HDT_LC_ComunicationsSearchListTstMock());

        Test.startTest();
        
        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj obj = (HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj) JSON.deserialize((String)HDT_LC_ComunicationsSearchList.getWsData(wrapperObj), HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj.class);
        
        System.assertEquals(true, obj.success, 'Si è verificato un errore in fase di chiamata al WS');
        String expectedBody = '{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": {}}';
        System.assertEquals(expectedBody, obj.body, 'Si è verificato un errore in fase di ricezione del body della response');

        Test.stopTest();
        
    }

    @isTest
    static void getWsDataHandleThrownException(){
        
        String wrapperObj = '';
        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj obj;

        try {
            Test.startTest();
        
            obj = (HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj) JSON.deserialize((String)HDT_LC_ComunicationsSearchList.getWsData(wrapperObj), HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj.class);

            Test.stopTest();
        } catch (Exception ex) {
            
            System.assertEquals(false, obj.success, 'success != false');
            System.assertEquals(null, obj.body, 'success != false');

        }
        
    }

    @isTest
    static void getWsDataFail(){
        
        String wrapperObj = '{"billingProfile":"123","documentCategory":"Bollette","customerAccount":"200005834844","startDate":"2019-07-17","endDate":"2019-07-18"}';
        Test.setMock(HttpCalloutMock.class, new HDT_LC_ComunicationsSearchListTstMockFail());

        Test.startTest();
        
        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj obj = (HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj) JSON.deserialize((String)HDT_LC_ComunicationsSearchList.getWsData(wrapperObj), HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj.class);
        
        System.assertEquals(false, obj.success, 'success != false');
        System.assertNotEquals(null, obj.message, 'message = null');


        Test.stopTest();
        
    }

    @IsTest
    static void getFakeData(){
        
        Test.startTest();

        String results = HDT_SRV_ComunicationsSearchList.getFakeData();

        System.assertNotEquals(null, results, 'results = null');

        Test.stopTest();
        
    }

    @isTest
    static void sendFileToPrint(){
        
        String requestObj = '{"billingProfile":"123","documentCategory":"Solleciti","customerAccount":"200005834844","startDate":"2019-07-17","endDate":"2019-07-18"}';
        Test.setMock(HttpCalloutMock.class, new HDT_LC_ComunicationsSearchListTstMock());

        Test.startTest();
        HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj response = HDT_LC_ComunicationsSearchList.sendFileToPrint(requestObj);

        System.assertEquals(true, response.success, 'Si è verificato un errore in fase di ricezione della response');
        System.assertEquals('', response.message, 'message != \'\'');

        Test.stopTest();

    }

    @isTest
    static void testWrapperObj(){
        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj webServiceObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj();
        webServiceObj.success = true;
        webServiceObj.message = 'message';
        webServiceObj.body = 'ok';
    
        HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj responseObj = new HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj();
        responseObj.success = true;
        responseObj.message = 'message';
        responseObj.dataError = true;
        responseObj.bodyBase64 = 'base64';

        System.assertNotEquals(null, webServiceObj, 'webServiceObj = null');
        System.assertNotEquals(null, responseObj, 'responseObj = null');

    }

    @isTest
    static void testGetCompanyCode(){

        Test.startTest();

        String companyCode = HDT_LC_ComunicationsSearchList.getCompanyCode('Hera Comm S.p.A.');
        System.assertEquals('1070', companyCode, 'Si è verificato un errore in fase di get del Company Code');

        Test.stopTest();

    }


    public class HDT_LC_ComunicationsSearchListTstMockFail implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status": "fail","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": {}}');
            response.setStatusCode(500);
            response.setStatus('KO');
            return response; 
        }
    }

}