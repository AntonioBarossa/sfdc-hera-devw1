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
             HDT_UTL_DataFactoryTst.newPhaseTransition('Preventivo scaduto','Ammissibilità OK',recordTypeId,'HDT_RT_ConnessioneConAttivazione');       
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accId);
            for(Contact c : contacts)
            {
                c.Company__c='MMS';
            }
            insert contacts;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(2,false,accId,'Preventivo Accettato');
            for(Order o : orders){
                o.Contact__c=contacts[0].id;
                o.Phase__c='Attesa conferma preventivo cliente';
                o.ValidityDateEstimate__c = system.today() - 1;
                o.RecordTypeId = constants.ORDER_RECORDTYPEID_CONNESSIONECONATTIVAZIONE;
            }
            orders[1].Phase__c = 'Ammissibilità OK';
            orders[1].QuotationType__c = 'Predeterminabile';
            insert orders;
        }
    }

    @isTest
    static void testSchedule(){
        
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

    @IsTest
    static void testRun()
    {
        Test.startTest();
            String jobId = Database.executeBatch(new HDT_BA_OrderEstimateExpiration(), 200);
        Test.stopTest();

        List<Order> orderExpired = [SELECT Id, Phase__c, Status FROM Order];
        System.assertNotEquals(null, jobId, 'Job non eseguito correttamente');
        System.assertEquals('Preventivo scaduto', orderExpired[0].Phase__c, 'Fase 1 non calcolata correttamente');
        System.assertEquals('Preventivo scaduto', orderExpired[1].Phase__c, 'Fase 2 non calcolata correttamente');
        System.assertEquals('Annullato', orderExpired[0].Status, 'Status non calcolato correttamente');
    }
}