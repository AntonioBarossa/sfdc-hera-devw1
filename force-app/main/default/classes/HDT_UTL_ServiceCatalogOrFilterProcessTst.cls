/**
 * Header of the class "HDT_UTL_ServiceCatalogOrFilterProcessTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_ServiceCatalogOrFilterProcess"
 * @history
 * @Created 29/09/2021
 * Modified By:
 **/

@isTest
public class HDT_UTL_ServiceCatalogOrFilterProcessTst {

	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
			Id accId = accs[0].id;
            HDT_UTL_DataFactoryTst.createCase(1,true,accId,null,null,null,null);
            
            List<Case> cases2 = HDT_UTL_DataFactoryTst.createCase(1,false,accId,null,null,null,null);
            for(Case c : cases2){
                c.type = 'Storno Rateizzazione';
            }
            insert cases2;
            
        }
     }

  @isTest
	static void testCaseFilter(){
        
        Case c = [Select id,cluster__c from Case where type != 'Storno Rateizzazione'];
        
        Test.startTest();
        
        Boolean res = HDT_UTL_ServiceCatalogOrFilterProcess.caseFilter(c, 'Fiscale');
        
        Test.stopTest();
        
        System.assertEquals(false, res, 'ServiceCatalogOrFilterProcess did not work correctly');
        
        System.assertNotEquals(null, res, 'Result not returned correctly');
        
    }
    
  @isTest
	static void testAccountStatementFilter(){
        
        Case c = [Select id,cluster__c from Case where type = 'Storno Rateizzazione'];
        
        Test.startTest();
        
        Boolean res = HDT_UTL_ServiceCatalogOrFilterProcess.caseFilter(c, 'Piano Rateizzazione');
        
        Test.stopTest();
        
        System.assertEquals(true, res, 'Case not found');
        
        System.assertNotEquals(null, res, 'Result not returned correctly');
        
    }
}