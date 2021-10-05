@istest
public class HDT_WS_ArrichmentDataEntityInvokerTst {
    @TestSetup
    static void makeData(){
        HDT_WS_Request rep = New HDT_WS_Request();
        HDT_UTL_DataFactoryTstTODELETE.createWebServiceConfiguration ('ArrichData.Entity', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-enrichment/entities', 'POST', 'MulesoftSalesforceUser');
        HDT_UTL_DataFactoryTstTODELETE.createWebServiceCredential ('MulesoftSalesforceUser', 'a74b50dbaac04215bfbf89a2ee315a80', '48fe5165a40c49aa9bf4b3d9bca2552f');
    }

    @istest 
    static void methodTst(){            
        String contratto = 'contratto';
        String pod = 'pod';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HDT_WS_ArrichmentDataEntityInvokerMck());
        HDT_WS_ArrichmentDataEntityResponse resp = HDT_WS_ArrichmentDataEntityInvoker.callService (contratto,pod);
        System.assertEquals('status',resp.status,'Equals to the Mocks value');
        System.assertNotEquals('correlation',resp.correlationId,'Not Equals to the Mocks value');
        Test.stopTest();
    }
   
}