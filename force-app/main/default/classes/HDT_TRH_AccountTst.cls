/**
 * Header of the class "HDT_TRH_AccountTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Class "HDT_TRH_Account"
 * @history
 * @Created 28/09/2021
 * Modified By:
 **/

@isTest
public class HDT_TRH_AccountTst {
    
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @isTest
    static void test1(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(2,false,'HERA COMM','Azienda','Aziende SME');
            accs[0].VATNumber__c='13288870150';
            accs[0].FiscalCode__c='KNMKST92D20Z100D';
            accs[1].VATNumber__c='13288870150';
            accs[1].FiscalCode__c='13288870150';
            insert accs;
            System.assertEquals(2, [Select id from Account].size(), 'One Account not inserted');
            
            accs[0].BirthDate__c = System.today();
            accs[0].isPartner = true;
            accs[0].Published__c = true;
            update accs;
            
            System.assertNotEquals(false, accs[0].Published__c, 'Account not updated');
            
        }
     }
}