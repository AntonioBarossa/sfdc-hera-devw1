/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 12/08/2021
 * @description HDT_TRH_CampaignMemberAssigmentItem for Test Classes
 * @history Fabricio Petkevicius Nunes – 12/08/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_CampaignMemberAssigmentItemTst{

	@isTest
	public static void testTriggerCampaignBeforeInsertAndUpdate(){

		Test.startTest();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<CampaignMemberAssigment__c> campMemAssig=HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'CampaignMemberAssigmentNameTest');
		List<CampaignMemberAssigmentItem__c> campMemAssigItens=HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, accounts[0].Id, campMemAssig[0].Id, 'Preview', 1);

		System.assertEquals(true, String.isNotEmpty(campMemAssigItens[0].Id), 'Campaign Member Assigment Item not Inserted');
		System.assertNotEquals(false, String.isNotEmpty(campMemAssigItens[0].Id), 'Campaign Member Assigment Item not Inserted');

		campMemAssigItens[0].PercentageAllocation__c=2;
		update campMemAssigItens;

		CampaignMemberAssigmentItem__c campMemAssigItemUpdated=[SELECT Id, PercentageAllocation__c
		                                                        FROM CampaignMemberAssigmentItem__c
		                                                        WHERE Id=:campMemAssigItens[0].Id];

		System.assertEquals(2, campMemAssigItemUpdated.PercentageAllocation__c, 'Campaign Member Assigment Item not updated');
		System.assertNotEquals(1, campMemAssigItemUpdated.PercentageAllocation__c, 'Campaign Member Assigment Item not updated');

		Test.stopTest();
	}
}