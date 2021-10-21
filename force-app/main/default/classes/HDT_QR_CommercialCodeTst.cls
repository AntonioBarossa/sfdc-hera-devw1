/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 14/09/2021
 * @description HDT_QR_CommercialCode Test Class
 * @history Lucas da Silva Fernandes – 14/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_QR_CommercialCodeTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_QR_CommercialCode qrCommCode = new HDT_QR_CommercialCode();
	
	@TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;
 
        System.runAs(internalUser) {

            List<Campaign> cmpList = HDT_UTL_DataFactoryTst.createCampaign(1, true);
 
            List<CommercialCode__c> ccList = HDT_UTL_DataFactoryTst.createCommCode(1, false);
            ccList[0].AvailabilityUsesEE__c = 2.0;
            ccList[0].AvailabilityUsesGAS__c = 2.0;
            ccList[0].AvailabilityUsesVAS__c = 2.0;
            ccList[0].ActualUsesEE__c = 1.0;
            ccList[0].ActualUsesGAS__c = 1.0;
            ccList[0].ActualUsesVAS__c = 1.0;
            ccList[0].Campaign__c = cmpList[0].Id;
            insert ccList;

        }
    }
	
	@isTest
    public static void testGetRecordById() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Id ccId = [SELECT Id FROM CommercialCode__c WHERE Name = 'testCommCode'].Id;

            CommercialCode__c cc = qrCommCode.getRecordById(ccId);
 
            Test.stopTest();

            System.assertEquals(ccId, cc.Id, 'CommercialCode successfully queried');
            System.assertNotEquals(null, cc.Id, 'CommercialCode query failed');
        }
    }

    @isTest
    public static void testGetCommercialCodeNumber() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            Id ccId = [SELECT Id FROM Campaign WHERE Name='Test Campaign'].Id;

            Set<Id> idSet = new Set<Id>();
            idSet.add(ccId);

            List<AggregateResult> arList = qrCommCode.getCommercialCodeNumber(idSet);
 
            Test.stopTest();

            System.assertEquals(false, arList.isEmpty(), 'AggregateResult successfully queried');
            System.assertNotEquals(null, arList.isEmpty(), 'AggregateResult query failed');
        }
    }
}
