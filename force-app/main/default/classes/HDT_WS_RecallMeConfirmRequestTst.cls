/**
 * Header of the class "HDT_WS_RecallMeConfirmRequestTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_RecallMeConfirmRequest"
 * @history
 * @Created 27/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_RecallMeConfirmRequestTst {

  @isTest
	static void test1(){
        
        HDT_WS_RecallMeConfirmRequest req = new HDT_WS_RecallMeConfirmRequest();
        
        req.timestamp = 123;
        req.idUser = 456;
        req.appointmentType = 'test';
        req.ecid = 'test';
        req.username = 'test';
        req.communicationType= 'test';
        
        System.assertEquals('test', req.username, 'Value of the field username not set');
        
        System.assertNotEquals(null, req, 'Request not created');

    }
}