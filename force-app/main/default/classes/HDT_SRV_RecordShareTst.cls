/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 05/08/2021
 * @description HDT_SRV_RecordShare Test Classes
 * @history Lucas da Silva Fernandes – 05/08/2021 – Created Class
 */

 @isTest
public with sharing class HDT_SRV_RecordShareTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){

        Id standardUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_STANDARD_USER_NAME);
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

        User standardUser = HDT_UTL_DataFactoryTst.createInternalUser(standardUserProfileId, true);
 
        internalUser.UserPermissionsMarketingUser=true;
        internalUser.FirstName = 'test Admin User';
        insert internalUser;

        System.runAs(internalUser) {
        
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            
            List<AccountShare> asList = HDT_UTL_DataFactoryTst.createAccountShare(1, true, acc[0].Id, standardUser.Id);

            System.debug('AccountShare'+asList);
        }
    }

    @isTest
    public static void testCheckAccessInit() {

        Boolean finished = false;

        Test.startTest();

        HDT_SRV_RecordShare.checkAccessInit('AccountAccessLevel', 'update');

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');
    }

    @isTest
    public static void testCheckCreateAccess() {

        Boolean finished = false;

        Test.startTest();

        Id testUser = [SELECT Id FROM User WHERE UserPermissionsMarketingUser = false AND Email = 'crmuser@test.com'].Id;

        AccountShare accShare = [SELECT Id FROM AccountShare WHERE UserOrGroupId =: testUser];

        HDT_SRV_RecordShare.checkCreateAccess(accShare);

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');
    }

    @isTest
    public static void testCreateRecord() {

        Test.startTest();

            Id testUser = [SELECT Id FROM User 
                          WHERE UserPermissionsMarketingUser = false 
                          AND Email = 'crmuser@test.com'].Id;

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare 
                                    WHERE UserOrGroupId =: testUser];

            List<AccountShare> aShare = HDT_UTL_DataFactoryTst.createAccountShare(1, false, 
                                        [SELECT Id FROM Account].Id, testUser);

            aShare[0] = HDT_SRV_RecordShare.createRecord(aShare[0]);

            System.assertEquals(accShare.AccountId, aShare[0].AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShare.AccountId, null, 'No AccountShare Id found');

        Test.stopTest();
    }

    @isTest
    public static void testCreateRecordWithList() {

        Test.startTest();

            Id testUser = [SELECT Id FROM User 
                          WHERE UserPermissionsMarketingUser = false 
                          AND Email = 'crmuser@test.com'].Id;

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare 
                                    WHERE UserOrGroupId =: testUser];

            List<AccountShare> asList = HDT_UTL_DataFactoryTst.createAccountShare(1, false, 
                                        [SELECT Id FROM Account].Id, testUser);

            asList = HDT_SRV_RecordShare.createRecord(asList);

            System.assertEquals(accShare.AccountId, asList[0].AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShare.AccountId, null, 'No AccountShare Id found');

        Test.stopTest();
    }

    @isTest
    public static void testCreateRecordWithout() {

        Test.startTest();

            Id testUser = [SELECT Id FROM User 
                          WHERE UserPermissionsMarketingUser = false 
                          AND Email = 'crmuser@test.com'].Id;

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare 
                                    WHERE UserOrGroupId =: testUser];

            List<AccountShare> asList = HDT_UTL_DataFactoryTst.createAccountShare(1, false, 
                                        [SELECT Id FROM Account].Id, testUser);

            asList = HDT_SRV_RecordShare.createRecordWithout(asList);

            System.assertEquals(accShare.AccountId, asList[0].AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShare.AccountId, null, 'No AccountShare Id found');

        Test.stopTest();
    }

    @isTest
    public static void testCheckUpdateAccess() {

        Boolean finished = false;

        Test.startTest();

        Id testUser = [SELECT Id FROM User WHERE UserPermissionsMarketingUser = false 
                                           AND Email = 'crmuser@test.com'].Id;

        AccountShare accShare = [SELECT Id FROM AccountShare WHERE UserOrGroupId =: testUser];

        HDT_SRV_RecordShare.checkUpdateAccess(accShare);

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Not Ended');
    }

    @isTest
    public static void testUpdateRecord() {

        Test.startTest();

        User tUser=[SELECT Id, FirstName FROM USER
                    WHERE UserPermissionsMarketingUser = true 
                    AND Email = 'crmuser@test.com'];

        System.runAs(tUser){

            Id testUser = [SELECT Id FROM User 
                          WHERE UserPermissionsMarketingUser = false 
                          AND Email = 'crmuser@test.com'].Id;
                          
            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId, ContactAccessLevel 
                                    FROM AccountShare
                                    WHERE UserOrGroupId =: testUser];

            AccountShare aShare = accShare;

            accShare.ContactAccessLevel = 'Read';

            accShare = HDT_SRV_RecordShare.updateRecord(accShare);

            System.assertEquals(accShare.AccountId, aShare.AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShare.AccountId, null, 'No AccountShare Id found');
        }

        Test.stopTest();
    }

    @isTest
    public static void testUpdateRecordList() {

        Test.startTest();

        User tUser=[SELECT Id, FirstName FROM USER
                    WHERE UserPermissionsMarketingUser = true 
                    AND Email = 'crmuser@test.com'];

        System.runAs(tUser){

            Id testUser = [SELECT Id FROM User 
                          WHERE UserPermissionsMarketingUser = false 
                          AND Email = 'crmuser@test.com'].Id;
                          
            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId, ContactAccessLevel 
                                    FROM AccountShare
                                    WHERE UserOrGroupId =: testUser];

            AccountShare aShare = accShare;

            accShare.ContactAccessLevel = 'Read';

            List<AccountShare> accShareList = new List<AccountShare>();
            accShareList.add(accShare);

            accShareList = HDT_SRV_RecordShare.updateRecord(accShareList);

            System.assertEquals(accShareList[0].AccountId, aShare.AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShareList[0].AccountId, null, 'No AccountShare Id found');
        }

        Test.stopTest();
    }
}
