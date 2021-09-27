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
        
	   Test.setMock(HttpCalloutMock.class, new HDT_WS_RecallMeMock());

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
        
        Test.setMock(HttpCalloutMock.class, new HDT_WS_RecallMeMock());
        
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
    
        public class HDT_WS_RecallMeMock implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            HttpResponse response = new HttpResponse();
            String body;
			List<HDT_WebServiceConfiguration__c> webServiceConfigurations = HDT_WebServiceConfiguration__c.getAll().values();

        	for(HDT_WebServiceConfiguration__c wsc : webServiceConfigurations) {
                if(request.getEndpoint() == wsc.Endpoint__c) {
                    if (wsc.Name == 'postSlotRequest') {
                    HDT_WS_RecallMeResponse dataresponse = new HDT_WS_RecallMeResponse(); 
                    List<HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap> reslt= new List<HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap>(); 
                    HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap resWrap= new HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap();  
                    resWrap.startTime = Long.valueOf(String.valueOf(System.now().getTime()));
                    resWrap.endTime = Long.valueOf(String.valueOf(System.now().getTime()));
                    resWrap.availability = 9;
                    reslt.add(resWrap);
                    dataresponse.result = reslt;
                    dataresponse.status = 'success';
        
                    body = JSON.serialize(dataresponse);
                    response.setStatusCode(200);
                    response.setBody(body);    
                    }else if(wsc.Name == 'postAppointment'){
                        response.setStatusCode(200);
                        response.setStatus('success'); 
                    }
                }
            }
            return response;

        }
    }
}