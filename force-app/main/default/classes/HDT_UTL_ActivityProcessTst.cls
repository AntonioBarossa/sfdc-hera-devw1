/**
 * Header of the class "HDT_UTL_ActivityProcessTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_ActivityProcess"
 * @history
 * @Created 27/09/2021
 * Modified By:
 **/

@isTest
public class HDT_UTL_ActivityProcessTst {

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
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accId);
            for(Contact c : contacts)
                c.Company__c='MMS';
            insert contacts;


            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(10, false, accId, 'Bozza');
            for(Order O : orders){
                o.OutgoingCreditCheckResult__c = 'no';
            	o.IncomingCreditCheckResult__c = 'no';
                o.CreditCheckDescription__c = 'CreditCheckDescription';
                o.Contact__c = contacts[0].id;
                o.CommentForDL__c = 'CommentForDL';               
            }            
            insert orders;            
        }
     }

  @isTest
	static void test1(){
        
        Map<String,List<Order>> orderMap = new Map<String,List<Order>>();
        List<Order> orders1 = [select OutgoingCreditCheckResult__c, IncomingCreditCheckResult__c, id, CreditCheckDescription__c, Contact__c, CommentForDL__c, AccountId from order];
        List<Order> orders2 = [select OutgoingCreditCheckResult__c, IncomingCreditCheckResult__c, id, CreditCheckDescription__c, Contact__c, CommentForDL__c, AccountId from order limit 5];
        
        orderMap.put('oldCustomer', orders1);
        orderMap.put('newCustomer', orders2);
        
        List<wrts_prcgvr__Activity__c> activitiesBefore = [select id,CreditCheckReason__c from wrts_prcgvr__Activity__c];
        
        Test.startTest();
        
        HDT_UTL_ActivityProcess.createActivity(orderMap);
        
        Test.stopTest();
        
        List<wrts_prcgvr__Activity__c> activitiesAfter = [select id,CreditCheckReason__c from wrts_prcgvr__Activity__c];
        
        System.assertEquals(15, activitiesAfter.size(), 'An activity is not created for each order');
        
        System.assertNotEquals(activitiesBefore.size(), activitiesAfter.size(), 'Activities not created');
                
    }
}