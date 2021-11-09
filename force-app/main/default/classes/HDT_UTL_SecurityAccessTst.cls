/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 23/09/2021
 * @description HDT_UTL_SecurityAccess Test Class
 * @history Lucas da Silva Fernandes – 23/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_UTL_SecurityAccessTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        Id minimumUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.MINIMUM_ACCESS_SALESFORCE);
        User minimumUser=HDT_UTL_DataFactoryTst.createInternalUser(minimumUserProfileId, false);
        minimumUser.UserPermissionsMarketingUser=true;
        minimumUser.Alias='testUser';
        insert minimumUser;
 
        System.runAs(internalUser) {
 
            HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        }
    }
	
	@isTest
    public static void testSecurityAccess() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            String msg;
            
            HDT_UTL_SecurityAccess saRead = new HDT_UTL_SecurityAccess('Account', 'BillingCityCode__c', 'read');
            HDT_UTL_SecurityAccess saCreate = new HDT_UTL_SecurityAccess('Account', 'BillingCityCode__c', 'create');
            HDT_UTL_SecurityAccess saUpdate = new HDT_UTL_SecurityAccess('Account', 'BillingCityCode__c', 'update');
            HDT_UTL_SecurityAccess saDelete = new HDT_UTL_SecurityAccess('Account', 'BillingCityCode__c', 'delete');
            HDT_UTL_SecurityAccess saUpsert = new HDT_UTL_SecurityAccess('Account', 'Id', 'upsert');
            HDT_UTL_SecurityAccess saUpdateFail = new HDT_UTL_SecurityAccess('Account', 'Id', 'update');
            HDT_UTL_SecurityAccess saDefault = new HDT_UTL_SecurityAccess('Account', 'Id', '');

            try {

                saRead.checkSecurityAccess();
                saCreate.checkSecurityAccess();
                saUpdate.checkSecurityAccess();
                saDelete.checkSecurityAccess();
                saUpdateFail.checkSecurityAccess();
                saUpsert.checkSecurityAccess();
                saDefault.checkSecurityAccess();
                
            } catch (Exception e) {
                msg = e.getMessage();
            }
 
            Test.stopTest();
            System.assertEquals('Script-thrown exception', msg, 'HDT_UTL_SecurityAccess did not work correctly');
            System.assertNotEquals(null, saDelete, 'HDT_UTL_SecurityAccess did not work correctly');
        }
    }
}