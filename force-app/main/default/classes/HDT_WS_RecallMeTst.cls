/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 27/09/2021
 * @description HDT_WS_RecallMe Test Class
 * @history Sabina Levonja – 27/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_WS_RecallMeTst {
    
 	@TestSetup
    static void makedata(){

       HDT_UTL_DataFactoryTst.createWebServiceConfiguration('postSlotRequest', 'end', 'method', 'testUser');
       HDT_UTL_DataFactoryTst.createWebServiceConfiguration('postAppointment', 'end', 'method', 'testUser');
       HDT_UTL_DataFactoryTst.createWebServiceCredential('FirstName LastName', 'pass12345', 'usernameTest');

    }
    
    @isTest
    static void testPostRecallMe(){
        
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);

       HDT_WS_RecallMeRequest req = new HDT_WS_RecallMeRequest();
       req.startRange = System.now().getTime();
       req.endRange= System.now().addDays(1).getTime();
       req.appointmentType= 'PERSONAL_PHONECALL';
       
       Test.startTest();
       HDT_WS_RecallMeResponse res = HDT_WS_RecallMe.postRecallMe('postSlotRequest', req);
       Test.stopTest();

       System.assertNotEquals(true, res.result.isEmpty(), 'The result is not empty');
       System.assertEquals(200, res.statusCode, 'The call has been successful');
    }
    
    @isTest
    static void testPostRecallMeAppointment(){
        
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
    	HDT_WS_RecallMeConfirmRequest req = new HDT_WS_RecallMeConfirmRequest();
        req.timestamp = System.now().getTime();
        req.appointmentType= 'PERSONALE';
        req.communicationType = 'CALL_AUTOMATIC';
                
        Test.startTest();
        HDT_WS_Response res = HDT_WS_RecallMe.postRecallMeAppointment('postAppointment', req);
        System.debug(res);
        Test.stopTest();
        
        System.assertNotEquals(null, res, 'A response was successfully created');
        System.assertEquals(200, res.statusCode, 'The call has been successful');

    }
}