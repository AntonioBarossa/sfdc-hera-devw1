/**
 * Header of the class "HDT_WS_RecallMeRequestTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_RecallMeRequest"
 * @history
 * @Created 27/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_RecallMeRequestTst {

  @isTest
	static void test1(){
        
        HDT_WS_RecallMeRequest req = new HDT_WS_RecallMeRequest();
        
        req.startRange = 1;
        req.endRange = 2;
        req.appointmentType = 'test';
        req.idUser = 123;
        req.username = 'test';
        req.ecid = 'test';
        
        System.assertEquals('test', req.username, 'Value of the field username not set');
        
        System.assertNotEquals(null, req, 'Request not created');

    }
}