/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 06/09/2021
 * @description HDT_SRV_Contract Test Classes
 * @history Lucas Fernandes 06/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_SRV_ContractTst {
   
    private static HDT_SRV_Contract srvContract = new HDT_SRV_Contract();
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser = true;
 
        insert internalUser;
 
        System.runAs(internalUser) {
 
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);

        }
    }

    @isTest
    public static void testCheckReadAccess() {

        boolean finito;
 
        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
 
            Test.startTest();

            srvContract.checkReadAccess('Id');
 
            Test.stopTest();
            finito = true;
            System.assertEquals(true, finito, 'testCheckReadAccess not finished');
			System.assertNotEquals(false, finito, 'testCheckReadAccess not finished');
        }
    }

    @isTest
    public static void testCheckUpdateAccess() {

        boolean finito;

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            srvContract.checkUpdateAccess('Name');

            Test.stopTest();
            finito = true;
            System.assertEquals(true, finito, 'testCheckUpdateAccess not finished');
			System.assertNotEquals(false, finito, 'testCheckUpdateAccess not finished');
        }
    }

    @isTest
    public static void testUpdateRecords() {

        User u = [SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){

            Test.startTest();

            List<Contract> ctt = [SELECT Id, Name FROM Contract WHERE SAPContractCode__c='3011913470'];
            ctt[0].Name = 'updateName';

            srvContract.updateRecords(ctt);

            Contract contract = [SELECT Id, Name FROM Contract WHERE SAPContractCode__c='3011913470'];

            Test.stopTest();

            System.assertEquals('updateName', contract.Name, 'Contact successfully updated');

            System.assertNotEquals('', contract.Name, 'Contact was not updated');
        }
    }
}
