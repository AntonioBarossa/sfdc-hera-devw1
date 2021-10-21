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
            HDT_UTL_DataFactoryTst.newPhaseTransition('DestinationPhase','OriginPhase',constants.ORDER_RECORDTYPEID_DEFAULT,constants.ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT);
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<Order> orders  = HDT_UTL_DataFactoryTst.createOrder(1,true,accId,'Bozza');
          
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();          

        }
    }
    
	@isTest
    static void testCreateActivityFromLead(){
        
        Map<String, Object> args = new Map<String, Object>();
        Wrts_prcgvr__PhaseTransition__c myTransition = [Select id from Wrts_prcgvr__PhaseTransition__c];
        Order myOrder = [Select id from Order];
        args.put('transition', myTransition);
        args.put('action', myTransition);
        args.put('method', 'Bozza');
        args.put('sender', myOrder);
        
        
        Test.startTest();
        
        HDT_UTL_PrClickDoubleTransaction pdt = new HDT_UTL_PrClickDoubleTransaction();
        Object result = pdt.execute(args);
               
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'Queueable'];
    	System.assertNotEquals(0, jobsScheduled.size(), 'expecting one queued job');
        
        System.assertEquals(null, result, 'The returned result should not be null');

    }
}