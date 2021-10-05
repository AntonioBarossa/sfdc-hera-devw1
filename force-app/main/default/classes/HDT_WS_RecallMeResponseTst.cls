/**
 * Header of the class "HDT_WS_RecallMeResponseTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_RecallMeResponse"
 * @history
 * @Created 27/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_RecallMeResponseTst {

  @isTest
	static void test1(){
        
        test.startTest();
        
        HDT_WS_RecallMeResponse res = new HDT_WS_RecallMeResponse();
        
        HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap responsew = new HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap();
        
        responsew.startTime = 11;
        responsew.endTime = 13;
        responsew.availability = 12;
        
        res.result = new List<HDT_WS_RecallMeResponse.HDT_WS_RecallMeResponseWrap>();
        
        res.result.add(responsew);
        
        Test.stopTest();
        
        System.assertEquals(12, res.result[0].availability, 'Value of the field availability not set');
        
        System.assertNotEquals(0, res.result.size(), 'One element not added successfully in the field result');
        
    }
}