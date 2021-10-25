/**
 * Header of the class "HDT_BA_ComfortCallTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_ComfortCall"
 * @history
 * @Created 04/10/2021
 * Modified By:
 **/
@isTest
public class HDT_BA_ComfortCallTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
	@TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',constants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE,constants.ORDER_RECORDTYPE_DEVELOPERNAME_CONNESSIONECONATTIVAZIONE);
                
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts)
                c.Company__c='MMS';
            insert contacts;
			Id contactId = contacts[0].id;
            Id anotherContactId = contacts[1].id;
            
            List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
            Id parentOrderId = parentOrders[0].id;
            parentOrders[0].Contact__c = contactId;
            parentOrders[0].phase__c = 'In attesa conferma cliente';
            parentOrders[0].recordTypeId = constants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            update parentOrders;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orders[0].qualityCall__c = true;
            orders[0].DateComfortCall__c = System.today() - 2;
            orders[0].ComfortCallDaysDue__c = 2;
            orders[0].ParentOrder__c = parentOrderId;
            orders[0].Contact__c = contactId;
            insert orders;
            orders[0].recordTypeId = constants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            orders[0].Phase__c = 'In attesa conferma cliente';
            update orders;
            
            Group g = new Group(Name = 'test', DeveloperName = 'HDT_QUE_ComfortQuality');
            
            List<Campaign> campaigns = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaigns[0].Name = 'Comfort Campaign';
            insert campaigns;
            Id campaignId = campaigns[0].id;
            
            List<Order> orders2 = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orders2[0].qualityCall__c = true;
            orders2[0].DateComfortCall__c = System.today() - 3;
            orders2[0].ComfortCallDaysDue__c = 6.2;
            orders2[0].ParentOrder__c = parentOrderId;
            orders2[0].Contact__c = anotherContactId;
            insert orders2;
            orders2[0].recordTypeId = constants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            orders2[0].Phase__c = 'In attesa conferma cliente';
            update orders2;
            
            List<Lead> leads =  HDT_UTL_DataFactoryTst.createLead(1, true);
            
            List<CampaignMember> members = HDT_UTL_DataFactoryTst.createCampaignMember(true, campaignId, leads, contacts);
  
        }
    }
    
    @isTest
    static void test1(){

        Test.startTest();
        
        HDT_BA_ComfortCall cc = new HDT_BA_ComfortCall();        
        Id batchId = Database.executeBatch(cc,200);
        
        Test.stopTest();
        
        System.assertEquals(1, [Select id From wrts_prcgvr__Activity__c].size(), 'HDT_BA_ComfortCall did not work correctly: wrong amount of custom activities');
        
        System.assertNotEquals(0, [Select id From CampaignMember].size() ,'HDT_BA_ComfortCall did not work correctly: wrong amount of CampaignMember');
    }
}