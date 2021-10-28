/**
 * Header of the class "HDT_CampaignMemberTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative trigger "HDT_CampaignMember"
 * @history
 * @Created 14/10/2021
 * Modified By:
 **/

@isTest
public with sharing class HDT_CampaignMemberTst{

	@isTest
	public static void test(){

        List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1,true); 

        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');

        List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accs[0].Id);
        contacts[0].Company__c = 'MMS';
        insert contacts;
        
        List<CommercialCode__c>  codes = HDT_UTL_DataFactoryTst.createCommCode(1, false);
        codes[0].FullCode__c = '105413333';
        insert codes;

        List<Campaign> camps = HDT_UTL_DataFactoryTst.createCampaign(1, false);
        camps[0].CodeManagementModel__c ='Porta un amico';
        camps[0].Channel__c = 'Bolletta';
        camps[0].Category__c= 'Campagna Outbound';
        camps[0].CodeGenerationRule__c = 'PrefissoProgressivo';
        camps[0].PrefixCode__c = 'TST';
        insert camps;

        test.startTest();

        List<CampaignMember> campMembers = HDT_UTL_DataFactoryTst.createCampaignMember(false, camps[0].id, leads, contacts);
        campMembers[0].PromoCommercialCode__c = codes[0].id;
        insert campMembers;         

        test.stopTest();

        System.assertEquals(1, [SELECT Id FROM CampaignMember].size(), 'Campaign Member not Inserted');
        System.assertNotEquals(null, campMembers, 'Campaign Member not Inserted');
    }
}