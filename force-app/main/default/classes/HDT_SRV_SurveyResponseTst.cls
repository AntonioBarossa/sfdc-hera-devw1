/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 14/09/2021
 * @description HDT_SRV_SurveyResponse Test Classes
 * @history Lucas da Silva Fernandes – 14/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_SurveyResponseTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            HDT_UTL_DataFactoryTst.createSurveyResponse(1, true);
        }
    }
	
	@isTest
    public static void testCheckCreateAccess() {

        Boolean finished = false;
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            SurveyResponse__c sr = [SELECT Id FROM SurveyResponse__c WHERE Name = 'testName'];

            HDT_SRV_SurveyResponse.checkCreateAccess(sr);

            finished = true;
 
            Test.stopTest();

            System.assertEquals(true, finished, 'Test Finished');
        }
    }

    @isTest
    public static void testCreateRecord() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            SurveyResponse__c sr = new SurveyResponse__c(
                Name = 'SurveyResponseTest'
            );

            HDT_SRV_SurveyResponse.createRecord(sr);
 
            List<SurveyResponse__c> srList = [SELECT Id FROM SurveyResponse__c WHERE Name = 'SurveyResponseTest'];

            Test.stopTest();

            System.assertEquals(false, srList.isEmpty(), 'Survey Response created.');
            System.assertNotEquals(true, srList.isEmpty(), 'Survey Response creation failed.');
        }
    }
}
