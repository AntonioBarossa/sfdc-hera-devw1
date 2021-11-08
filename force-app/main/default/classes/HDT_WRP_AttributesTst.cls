/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 22/09/2021
 * @description HDT_WRP_Attributes Test Class
 * @history Lucas da Silva Fernandes – 22/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_WRP_AttributesTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
    }

    @isTest
    public static void testCreateAttributes() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            HDT_WRP_Attributes att = new HDT_WRP_Attributes();

            System.assertEquals('', att.email, 'HDT_WRP_Attributes did not work correctly');
            System.assertNotEquals(null, att, 'HDT_WRP_Attributes did not work correctly');
 
            Test.stopTest();
        }
    }
}
