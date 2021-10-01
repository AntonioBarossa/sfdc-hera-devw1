/**
 * Header of the class "HDT_AccountTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Trigger "HDT_Account"
 * @history
 * @Created 28/09/2021
 * Modified By:
 **/

@isTest
public class HDT_AccountTst {
    
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @isTest
    static void test1(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
                       
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
            
            System.assertEquals(1, accs.size(), 'Account not inserted');
            
        }
     }
}