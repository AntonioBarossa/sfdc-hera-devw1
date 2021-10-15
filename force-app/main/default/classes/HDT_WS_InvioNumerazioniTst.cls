/**
 * Header of the class "HDT_WS_InvioNumerazioniTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_InvioNumerazioni"
 * @history
 * @Created 27/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_InvioNumerazioniTst {
    
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('InvioNumerazioni','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
                        
        }
     }

  @isTest
	static void test1(){

        String macroactivity = 'macro';
        String phonenumber = 'phone';
        
        test.startTest();
        
        HDT_WS_Response res = HDT_WS_InvioNumerazioni.callService(macroactivity,phonenumber);
        
        test.stopTest();
        
        System.assertNotEquals(null, res, 'A response was not created');
        
        System.assertEquals(null, res.body, 'The respose fields should be set to null since the mock is not instantiated');
        
    }
}