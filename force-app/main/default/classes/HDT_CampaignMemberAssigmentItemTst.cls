/**
 * Header of the class "HDT_CampaignMemberAssigmentItemTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative trigger "HDT_CampaignMemberAssigmentItem"
 * @history
 * @Created 12/10/2021
 * Modified By:
 **/

@isTest
public class HDT_CampaignMemberAssigmentItemTst {
    
    @isTest static void test(){
        
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
        
        List<CampaignMemberAssigment__c> assignements = HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'CampaignMemberAssigmentNameTest');
        
        Test.startTest();
        
        List<CampaignMemberAssigmentItem__c> items =  HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, accs[0].id, assignements[0].id, 'Preview', 1);

        System.assertEquals(1, [Select id From CampaignMemberAssigmentItem__c].size(), 'CampaignMemberAssigmentItem not inserted correctly');

        System.assertNotEquals(null, items, 'CampaignMemberAssigmentItem not inserted correctly');

        Test.stopTest();
        
    }

}