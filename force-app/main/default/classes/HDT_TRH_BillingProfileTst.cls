/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 06/08/2021
 * @description HDT_TRH_BillingProfile for Test Classes
 * @history Fabricio Petkevicius Nunes – 06/08/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_BillingProfileTst{

	@isTest
	public static void testTriggerBillingProfileBeforeInsert(){

        Test.startTest();
		
			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);
		
            BillingProfile__c testBillProf = [SELECT Id,ContractAccountCode__c FROM BillingProfile__c WHERE ContractAccountCode__c='200008867681' LIMIT 1];
		
			
            System.assertEquals('200008867681', testBillProf.ContractAccountCode__c, 'BillingProfile ContractAccountCode__c field is not Inserted(BillingProfile Trigger)');
            System.assertNotEquals(null, testBillProf.Id,'BillingProfile id is empty (BillingProfile Trigger)');
			Test.stopTest();
		}
	}

	
