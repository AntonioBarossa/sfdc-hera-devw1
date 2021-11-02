/**
 * Header of the class "HDT_BA_OrderEstimateExpirationTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_OrderEstimateExpiration"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/
@isTest
public class HDT_BA_OrderEstimateExpirationTst {
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
            Id recordtypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConnessioneConAttivazione').getRecordTypeId();
            HDT_UTL_DataFactoryTst.newPhaseTransition('Preventivo scaduto','Attesa conferma preventivo cliente',recordTypeId,'HDT_RT_ConnessioneConAttivazione');
        
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accId);
            for(Contact c : contacts)
                c.Company__c='MMS';
            insert contacts;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Preventivo Accettato');
            for(Order o : orders){
                o.Contact__c=contacts[0].id;
                o.Phase__c='Attesa conferma preventivo cliente';
                o.ValidityDateEstimate__c = system.today() - 1;
                o.RecordTypeId = constants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;

            }
            insert orders;
        }
    }

    @isTest
    static void test(){
        
        String crono = '20 30 8 10 2 ?';
        
        Test.startTest();
        
		HDT_BA_OrderEstimateExpiration oee = new HDT_BA_OrderEstimateExpiration();
        String jobId = System.schedule('Label', crono , oee);
        
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'job not scheduled correctly');
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
    }
}