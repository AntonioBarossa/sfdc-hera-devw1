/**
 * Header of the class "HDT_LC_ReportNavigatorControllerTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_ReportNavigatorController"
 * @history
 * @Created 01/10/2021
 * Modified By:
 **/
@isTest(SeeAllData=true)
public class HDT_LC_ReportNavigatorControllerTst {
    
	@isTest
    static void testException(){
        
        Exception ex;
        String msg;
        
        Test.startTest();
        
        try{
            
        	HDT_LC_ReportNavigatorController.getReportId('randomstring');
            
        }catch(Exception e){
            ex = e;
            msg = e.getMessage();
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, ex, 'Exception not thrown');
        
        System.assertEquals('Script-thrown exception', msg, 'Report found when the input was a random string');

    }
    
    @isTest
    static void test(){
        
        String reportName = [Select DeveloperName From Report LIMIT 1].DeveloperName;
        
        Test.startTest();
        
        Id result = HDT_LC_ReportNavigatorController.getReportId(reportName);
        
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result not returned');
        
        System.assertEquals([SELECT id FROM Report WHERE DeveloperName =: reportName].id, result, 'Report id not returned');

    }
}