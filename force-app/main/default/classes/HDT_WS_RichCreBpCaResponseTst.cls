/**
 * Header of the class "HDT_WS_RichCreBpCaResponseTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_RichCreBpCaResponse"
 * @history
 * @Created 27/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_RichCreBpCaResponseTst {
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
	static void test1(){
        
        test.startTest();
        
        HDT_WS_RichCreBpCaResponse res = new HDT_WS_RichCreBpCaResponse();
        
        HDT_WS_RichCreBpCaResponse.dataResponseWrap datawrap = new HDT_WS_RichCreBpCaResponse.dataResponseWrap();
        
        String s = 'teststring';
        
        datawrap.codiceBP = s;
        datawrap.codiceBPAlternativo = s;
        datawrap.codiceCausale = s;
        datawrap.codiceContatto = s;
        datawrap.commenti = s;
        datawrap.rdo = s;
        datawrap.rds = s;
        datawrap.tipoAttivita = s;    
        
        res.data = datawrap;
        
        Test.stopTest();
        
        System.assertEquals(s, res.data.rdo, 'Value of the field rdo not set');
        
        System.assertNotEquals(null, res.data, 'Value of the field dataResponseWrap not set');
        
    }
}