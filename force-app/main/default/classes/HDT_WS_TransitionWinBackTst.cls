/**
 * Header of the class "HDT_WS_TransitionWinBackTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_TransitionWinBack"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_TransitionWinBackTst {

	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('TransitorioWinback','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
            
            
        }
     }

  @isTest
	static void test1(){
        
        HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse response = HDT_WS_TransitionWinBack.callTransitionCom('str');
		HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse anotherResponse = new HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse();
        HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj transitionOb1 = new HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj();
        transitionOb1.effectiveDate = 'test';
        transitionOb1.pod = 'test';
        transitionOb1.status = 'test';
        HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj transitionOb2 = new HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj();
        transitionOb2.effectiveDate = 'test';
        transitionOb2.pod = 'test';
        transitionOb2.status = 'test';
        
        anotherResponse.result = new List< HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj>();
        anotherResponse.result.add(transitionOb1);
        anotherResponse.result.add(transitionOb2);
        
        System.assertEquals('test', anotherResponse.result[0].pod, 'Value of the field pod not set');
        
        System.assertNotEquals(null, response, 'The method did not return a response');
        
    }
}