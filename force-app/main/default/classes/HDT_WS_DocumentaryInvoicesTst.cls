/**
* @author Elvin Iluca
* @date 12/12/2022
* @description Test Class for HDT_WS_DocumentaryInvoices.cls
* @history Elvin Iluca – 12/12/2022 – Created class
*/

@isTest
public with sharing class HDT_WS_DocumentaryInvoicesTst {
    /**​
    * @author Elvin Iluca
    * @date 12/12/2022
    * @description HDT_WS_DocumentaryInvoicesTst – Test Class for HDT_WS_DocumentaryInvoices.cls
    */

    @isTest
    static void sendFileSuccess(){
        HDT_WS_DocumentaryInvoices.HDT_WRP_ReturnObj ret; 
        HttpRequest req = new HttpRequest();

        HDT_WRP_ReponseObj myBody = new HDT_WRP_ReponseObj();
        myBody.status = 'success'; 
        myBody.data = new HDT_WS_DocumentaryInvoices.HDT_WRP_DataObj();

        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentaryInvoicesTstMock(myBody));
        Test.startTest();
        ret = HDT_WS_DocumentaryInvoices.sendFile(req);
        Test.stopTest();
        
        System.assertEquals(ret.success, true, 'Error HTTP callout');
    }

    @isTest
    static void sendFileFailed(){
        HDT_WS_DocumentaryInvoices.HDT_WRP_ReturnObj ret; 
        HttpRequest req = new HttpRequest();

        HDT_WRP_ReponseObj myBody = new HDT_WRP_ReponseObj();
        myBody.status = 'failed'; 
        myBody.data = new HDT_WS_DocumentaryInvoices.HDT_WRP_DataObj();

        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentaryInvoicesTstMock(myBody));
        Test.startTest();
        ret = HDT_WS_DocumentaryInvoices.sendFile(req);
        Test.stopTest();

        System.assertEquals(ret.success, false, 'Error HTTP callout');
    }

    
    @isTest
    static void sendFileError(){
        HDT_WS_DocumentaryInvoices.HDT_WRP_ReturnObj ret; 
        HttpRequest req = new HttpRequest();

        HDT_WRP_ReponseObj myBody;

        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentaryInvoicesTstMock(myBody));
        Test.startTest();
        ret = HDT_WS_DocumentaryInvoices.sendFile(req);
        Test.stopTest();

        System.assertEquals(ret.success, false, 'Error HTTP callout');
    }


      /**​
    * @author Elvin Iluca
    * @date 12/12/2022
    * @description HDT_WS_DocumentaryInvoicesTstMockTst – Test Class for HDT_WS_DocumentaryInvoicesTstMock.cls
    */

    public class HDT_WS_DocumentaryInvoicesTstMock implements HttpCalloutMock {
        HDT_WRP_ReponseObj myBody;

        HDT_WS_DocumentaryInvoicesTstMock(HDT_WRP_ReponseObj myBody){
            this.myBody=myBody;
        }
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(myBody));
            //response.setStatusCode(200);
            return response; 
        }
    }

    public class HDT_WRP_ReponseObj {
        String status;
        String correlationId;
        String timestamp;
        String message;
        HDT_WS_DocumentaryInvoices.HDT_WRP_DataObj data;
    }
}
