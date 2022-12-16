/**
 * Header of the class "HDT_UTL_PrClickDoubleTransactionTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_PrClickDoubleTransaction"
 * @history
 * @Created 29/09/2021
 * Modified By:
 **/
@isTest
public class HDT_UTL_PrClickDoubleTransactionTst {
    
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
            HDT_UTL_DataFactoryTst.pClickCasePhase();

            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','G6 - MMS Associazione','Aziende SME');
            Id accId = accs[0].id;
            HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
            HDT_UTL_DataFactoryTst.createCase(1, true, accId, null, null, null, null);

        }
    }
    
	@isTest
    static void testCreateActivityFromLeadOrder(){
        
        Map<String, Object> args = new Map<String, Object>();

        Order myOrder = [Select id from Order];

        args.put('method', 'Bozza');
        args.put('sender', myOrder);        
        
        Test.startTest();
        
        HDT_UTL_PrClickDoubleTransaction pdt = new HDT_UTL_PrClickDoubleTransaction();
        Object result = pdt.execute(args);
               
        Test.stopTest();
        
        System.assertEquals(null, result, 'CreateActivityFromLead did not work correctly');
        
        HDT_UTL_PrClickDoubleTransaction.enqueueDoublePhaseTransactions();

		List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'Queueable'];
        
    	System.assertNotEquals(0, jobsScheduled.size(), 'expecting one queued job');

    }
    
    @isTest
    static void testCreateActivityFromLeadCase(){
        
        Map<String, Object> args = new Map<String, Object>();

        Case myCase = [Select id from Case];

        args.put('method', 'Bozza');
        args.put('sender', myCase);        
        
        Test.startTest();
        
        HDT_UTL_PrClickDoubleTransaction pdt = new HDT_UTL_PrClickDoubleTransaction();
        Object result = pdt.execute(args);
               
        Test.stopTest();
 
        System.assertEquals(null, result, 'CreateActivityFromLead did not work correctly');
        
        HDT_UTL_PrClickDoubleTransaction.enqueueDoublePhaseTransactions();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'Queueable'];
        
    	System.assertNotEquals(0, jobsScheduled.size(), 'expecting one queued job');

        // Cover QBI bulk update constructor
        HDT_UTL_PrClickDoubleTransaction.HDT_QBL_BulkUpdate testConstructor = new HDT_UTL_PrClickDoubleTransaction.HDT_QBL_BulkUpdate(new Map<Id, String>(), new Map<Id, String>());

    }
}