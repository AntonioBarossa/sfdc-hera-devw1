/**
* Header of the class "HDT_QR_CampaignMemberAssigmentItemTst"
* @author: Luca Belometti 
* @version 1.0
* @description: Apex Test Class for HDT_QR_CampaignMemberAssigmentItem ( getRecordById Obj CampaignMemberAssigmentItem__c )
* @history
* Created: 2021-08-05
* Modified By:
**/

@isTest
public with sharing class HDT_QR_CampaignMemberAssigmentItemTst {
	@TestSetup
	static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<CampaignMemberAssigment__c> campaignMemeberAssignmentList = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true,true, 'CampaignMemberAssigmentNameTest');
        List<CampaignMemberAssigmentItem__c> campaignMemeberAssignmentItemList;
        campaignMemeberAssignmentItemList = HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true,accList[0].Id,campaignMemeberAssignmentList[0].Id,'Preview',10);
    }
    
    @isTest
    private static Void testGetRecordById() {
        List<CampaignMemberAssigmentItem__c> listCmai = [SELECT Id FROM CampaignMemberAssigmentItem__c];
        HDT_QR_CampaignMemberAssigmentItem campaingMemberClass = new HDT_QR_CampaignMemberAssigmentItem();
        Test.startTest();
        CampaignMemberAssigmentItem__c checkId =  campaingMemberClass.getRecordById(listCmai[0].Id);
        Test.stopTest();
        System.assertEquals(listCmai[0].Id, checkId.Id, 'Records has the Same IDs');
    }

    @isTest
    private static Void testGetItemsByCampaignMemberAssigmentId() {
        List<CampaignMemberAssigmentItem__c> listCmai = [SELECT Id,CampaingMemberAssigment__c FROM CampaignMemberAssigmentItem__c];
        HDT_QR_CampaignMemberAssigmentItem campaingMemberClass = new HDT_QR_CampaignMemberAssigmentItem();
        Test.startTest();
        List<CampaignMemberAssigmentItem__c> checkId =  campaingMemberClass.getItemsByCampaignMemberAssigmentId(listCmai[0].CampaingMemberAssigment__c);
        Test.stopTest();

        System.assertEquals(1, checkId.size(), 'List has 1 record in it');

    }
}
