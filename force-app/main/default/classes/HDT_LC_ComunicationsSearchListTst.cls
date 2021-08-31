@isTest
public class HDT_LC_ComunicationsSearchListTst {

    @testSetup
    static void setup() {
        Account a = new Account();
        a.CustomerCode__c = '0001';
        a.Name = 'accountTest';
        insert a;
    }

    @isTest
    static void getWsData(){
        
        String wrapperObj = '{"billingProfile":"123","documentCategory":"Solleciti","customerAccount":"200005834844","startDate":"2019-07-17","endDate":"2019-07-18"}';
        Test.setMock(HttpCalloutMock.class, new HDT_LC_ComunicationsSearchListTstMock());

        Test.startTest();
        Object obj = HDT_LC_ComunicationsSearchList.getWsData(wrapperObj);
        Test.stopTest();

        //System.assertEquals(true, tabMetadata.success, '');
        //System.assertEquals(10, tabMetadata.tabDetail.size(), '');
        
    }

    @isTest
    static void sendFileToPrint(){
        
        String requestObj = '{"billingProfile":"123","documentCategory":"Solleciti","customerAccount":"200005834844","startDate":"2019-07-17","endDate":"2019-07-18"}';
        Test.setMock(HttpCalloutMock.class, new HDT_LC_ComunicationsSearchListTstMock());

        Test.startTest();
        HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj response = HDT_LC_ComunicationsSearchList.sendFileToPrint(requestObj);
        Test.stopTest();

        //System.assertEquals(true, tabMetadata.success, '');
        //System.assertEquals(10, tabMetadata.tabDetail.size(), '');
        
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
    }

}