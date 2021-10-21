/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 23/09/2021
 * @description HDT_TRH_IndividualEmailResult Test Classes
 * @history Fabricio Petkevicius Nunes – 23/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_IndividualEmailResultTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserRoleId=HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_BACKOFFICE);
		insert internalUser;

        System.runAs(internalUser){
            HDT_UTL_DataFactoryTst.pClickInstance();
        }
	}

	@isTest
	public static void testTriggerIndEmailResultBeforeAfterInsertUpdate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();
           
			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);
			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, true);
            List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
	        List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
            List<Opportunity> opps =HDT_UTL_DataFactoryTst.createOpportunity(1, true);
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
            List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
            List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].Id, contacts[0].Id, spList[0].Id, contractList[0].Id, orderList[0].Id);

            List<et4ae5__Automated_Send__c> autoSend = HDT_UTL_DataFactoryTst.createTriggeredSend(1, true);
            List<et4ae5__IndividualEmailResult__c> indEmailResult = HDT_UTL_DataFactoryTst.createIndividualEmailResult(1, true, autoSend[0].Id);
            indEmailResult[0].Account__c = accounts[0].Id;
            indEmailResult[0].et4ae5__Lead__c = leads[0].Id;
            indEmailResult[0].CaseID__c = caseList[0].Id;
            indEmailResult[0].et4ae5__Contact__c = contacts[0].Id;
            indEmailResult[0].OrderID__c = orderList[0].Id;
            indEmailResult[0].BounceSubCategory__c = 'testBounceSubCat';
            indEmailResult[0].Name = 'testUpdate';
            update indEmailResult;

			test.stopTest();

            List<et4ae5__IndividualEmailResult__c> tIndEmailResult = [SELECT Id, Name FROM et4ae5__IndividualEmailResult__c WHERE Name = 'testUpdate'];

			System.assertEquals(true, tIndEmailResult[0].Id!=null, 'Individual Email Result not created');
			System.assertNotEquals(false, tIndEmailResult[0].Id!=null);
		}
	}
}