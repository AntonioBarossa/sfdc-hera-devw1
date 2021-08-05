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
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;

        System.runAs(internalUser) {
        
            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            
            List<AccountShare> asList = new List<AccountShare>();

            insert asList;
        }
    }

    @isTest
    public static void testCheckAccessInit() {

        Test.startTest();

        HDT_SRV_RecordShare.checkAccessInit('AccountAccessLevel', 'update');

        Test.stopTest();
    }

    @isTest
    public static void testCheckCreateAccess() {

        Test.startTest();

        AccountShare accShare = new AccountShare();

        accShare = [SELECT Id FROM AccountShare];

        HDT_SRV_RecordShare.checkCreateAccess(accShare);

        Test.stopTest();
    }

    @isTest
    public static void testCreateRecord() {

        Test.startTest();

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare];

            List<AccountShare> aShare = HDT_UTL_DataFactoryTst.createAccountShare(1, false, 
                                    [SELECT Id FROM Account].Id, [SELECT Id FROM USER 
                                    WHERE UserPermissionsMarketingUser=true AND IsActive=true
                                    LIMIT 1].Id);

            aShare[0] = HDT_SRV_RecordShare.createRecord(aShare[0]);

            System.assertEquals(accShare.AccountId, aShare[0].AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShare.AccountId, null, 'No AccountShare Id found');

        Test.stopTest();
    }

    @isTest
    public static void testCreateRecordWithList() {

        Test.startTest();

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare];

            List<AccountShare> asList = HDT_UTL_DataFactoryTst.createAccountShare(1, false, 
                                    [SELECT Id FROM Account].Id, [SELECT Id FROM USER 
                                    WHERE UserPermissionsMarketingUser=true AND IsActive=true
                                    LIMIT 1].Id);

            asList = HDT_SRV_RecordShare.createRecord(asList);

            System.assertEquals(accShare.AccountId, asList[0].AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShare.AccountId, null, 'No AccountShare Id found');

        Test.stopTest();
    }

    @isTest
    public static void testCreateRecordWithout() {

        Test.startTest();

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare];

            List<AccountShare> asList = HDT_UTL_DataFactoryTst.createAccountShare(1, false, 
                                    [SELECT Id FROM Account].Id, [SELECT Id FROM USER 
                                    WHERE UserPermissionsMarketingUser=true AND IsActive=true
                                    LIMIT 1].Id);

            asList = HDT_SRV_RecordShare.createRecordWithout(asList);

            System.assertEquals(accShare.AccountId, asList[0].AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShare.AccountId, null, 'No AccountShare Id found');

        Test.stopTest();
    }

    @isTest
    public static void testCheckUpdateAccess() {

        Test.startTest();

        AccountShare accShare = new AccountShare();

        accShare = [SELECT Id FROM AccountShare];

        HDT_SRV_RecordShare.checkUpdateAccess(accShare);

        Test.stopTest();
    }

    @isTest
    public static void testUpdateRecord() {

        Test.startTest();

        User tUser=[SELECT Id, FirstName FROM USER
                    WHERE Email = 'crmuser@test.com'
                    LIMIT 1];

        System.runAs(tUser){

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId, ContactAccessLevel FROM AccountShare];

            AccountShare aShare = accShare;

            accShare.ContactAccessLevel = 'Edit';

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
                    WHERE Email = 'crmuser@test.com'
                    LIMIT 1];

        System.runAs(tUser){

            AccountShare accShare = [SELECT Id, UserOrGroupId, AccountId, ContactAccessLevel FROM AccountShare];

            AccountShare aShare = accShare;

            accShare.ContactAccessLevel = 'Edit';

            List<AccountShare> accShareList = new List<AccountShare>();
            accShareList.add(accShare);

            accShareList = HDT_SRV_RecordShare.updateRecord(accShareList);

            System.assertEquals(accShareList[0].AccountId, aShare.AccountId, 'AccountShare Id returns the expected value.');

            System.assertNotEquals(accShareList[0].AccountId, null, 'No AccountShare Id found');
        }

        Test.stopTest();
    }
}
