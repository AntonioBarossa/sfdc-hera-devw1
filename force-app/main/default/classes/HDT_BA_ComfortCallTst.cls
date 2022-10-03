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
            HDT_UTL_DataFactoryTst.newPhaseTransition('In attesa conferma cliente','Bozza',constants.ORDER_RECORDTYPEID_SWITCHIN,constants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);    

            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts) {
                c.Company__c='MMS';
            }

            insert contacts;
			Id contactId = contacts[0].id;
            Id anotherContactId = contacts[1].id;
            
            List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
            Id parentOrderId = parentOrders[0].id;
            parentOrders[0].Contact__c = contactId;
            parentOrders[0].recordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            update parentOrders;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orders[0].qualityCall__c = true;
            orders[0].DateComfortCall__c = System.today() - 5;
            orders[0].ComfortCallDaysDue__c = 2;
            orders[0].ParentOrder__c = parentOrderId;
            orders[0].Contact__c = contactId;
            insert orders;
            orders[0].recordTypeId = constants.ORDER_RECORDTYPEID_SWITCHIN;
            orders[0].Phase__c = 'In attesa conferma cliente';
            update orders;
            
            // Group g = new Group(Name = 'test', DeveloperName = 'HDT_QUE_ComfortQuality');
            
            List<Campaign> campaigns = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaigns[0].Name = 'Comfort Campaign';
            campaigns[0].Tipology__c = 'Comfort Call';
            campaigns[0].Status = 'In Corso';
            campaigns[0].CompanyOwner__c = 'MMS';
            insert campaigns;
            
            List<Order> ordersDuplicate = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            ordersDuplicate[0].qualityCall__c = true;
            ordersDuplicate[0].DateComfortCall__c = System.today() - 3;
            ordersDuplicate[0].ComfortCallDaysDue__c = 6.2;
            ordersDuplicate[0].ParentOrder__c = parentOrderId;
            ordersDuplicate[0].Contact__c = anotherContactId;
            insert ordersDuplicate;
            ordersDuplicate[0].recordTypeId = constants.ORDER_RECORDTYPEID_SWITCHIN;
            ordersDuplicate[0].Phase__c = 'In attesa conferma cliente';
            update ordersDuplicate;
  
        }
    }
    
    @isTest
    static void test(){

        Test.startTest();
        
        HDT_BA_ComfortCall cc = new HDT_BA_ComfortCall();        
        Database.executeBatch(cc,200);
        
        Test.stopTest();
        
        System.assertEquals(1, [Select id From wrts_prcgvr__Activity__c].size(), 'HDT_BA_ComfortCall did not work correctly: wrong amount of custom activities');
        
        System.assertNotEquals(0, [Select id From CampaignMember].size() ,'HDT_BA_ComfortCall did not work correctly: wrong amount of CampaignMember');
    }
}