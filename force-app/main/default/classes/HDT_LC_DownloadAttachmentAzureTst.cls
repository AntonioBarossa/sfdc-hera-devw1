/**
 * Header of the class "HDT_LC_DownloadAttachmentAzureTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_DownloadAttachmentAzure"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/

@isTest
public class HDT_LC_DownloadAttachmentAzureTst {
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
            
            
        }
     }

  @isTest
	static void testGetUrlNameDocumentLink(){
        String msg;
        String targetId = 'test';
        try{
        	String s = HDT_LC_DownloadAttachmentAzure.getUrlNameDocumentLink(targetId);
        }catch(Exception e){
            msg = e.getMessage();
        }
        System.assertEquals('Script-thrown exception', msg, 'DownloadAttachmentAzure did not work correctly');
        System.assertNotEquals('', msg, 'The exception message is empty');
        
    }
}