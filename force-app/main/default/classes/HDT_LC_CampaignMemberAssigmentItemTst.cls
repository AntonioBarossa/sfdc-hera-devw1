/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 13/08/2021
 * @description HDT_LC_CampaignMemberAssigmentItem Test Class
 * @history Lucas da Silva Fernandes - 13/08/2021 - Class Creation
 */

 @isTest
public with sharing class HDT_LC_CampaignMemberAssigmentItemTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        System.runAs(internalUser) {

            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<CampaignMemberAssigment__c> cmaList = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'YMCA');
            HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, accList[0].Id, cmaList[0].Id, 'Preview', 10);
        }
    }

    @isTest
    public static void testGetItemsByMemberAssignment () {

        Test.startTest();

        CampaignMemberAssigment__c cma = [SELECT Id FROM CampaignMemberAssigment__c WHERE Name = 'YMCA' LIMIT 1];

        List<CampaignMemberAssigmentItem__c> cmaiList = HDT_LC_CampaignMemberAssigmentItem.getItemsByMemberAssignment(cma.Id);

        System.assertEquals('Preview', cmaiList[0].ProcessingType__c, 'CampaignMemberAssigmentItem ProcessingType__c is correct');

        System.assertNotEquals(null, cmaiList[0].ProcessingType__c, 'CampaignMemberAssigmentItem ProcessingType__c is not correct');

        Test.stopTest();
    }
}
