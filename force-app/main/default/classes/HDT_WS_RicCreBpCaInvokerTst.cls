/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 28/09/2021
* @description HDT_WS_RicCreBpCaInvoker for Test Classes
* @history Elfrida Kora – 28/09/2021 – Created class
*/


@IsTest
public class HDT_WS_RicCreBpCaInvokerTst {
    
    @TestSetup
    static void makedata(){

       HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA', 'testUser', 'method', 'end');
       HDT_UTL_DataFactoryTst.createWebServiceCredential('FirstName LastName', 'pass321', 'myUser');
        

    }
    
    @isTest
    static void testInvokeCall(){
        
        Test.setMock(HttpCalloutMock.class, new HDT_WS_HTTPServiceCallMock());
        
        HDT_WS_RicCreBpCaRequest req = new HDT_WS_RicCreBpCaRequest();
        req.account.nome = 'test';
        req.codiceCausale = 'CBP';
        req.numeroSR = '78df7d8';
        
         Test.startTest();
       HDT_WS_RichCreBpCaResponse res = HDT_WS_RicCreBpCaInvoker.invokeCall(req); 
       Test.stopTest();
        
       System.assertEquals(200, res.statusCode, 'The call was not successful');
       System.assertNotEquals(null, res, 'A response was successfully created');

    }

}