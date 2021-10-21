/**
 * Header of the class "HDT_UTL_ServiceCatalogOrFilterTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_ServiceCatalogOrFilter"
 * @history
 * @Created 30/09/2021
 * Modified By:
 **/

@isTest
public class HDT_UTL_ServiceCatalogOrFilterTst {

	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickCasePhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('DestinationPhase','OriginPhase',constants.CASE_RECORDTYPEID_MOROSITA,constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA);
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
			Id accId = accs[0].id;
            
            List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1,true,accId,null,null,null,null);
            
            AccountStatementFilter__c asf = new AccountStatementFilter__c();
            insert asf;
            
        }
     }

  	@isTest
	static void test1(){
        
        Case c = [Select id From Case];
        Wrts_prcgvr__PhaseTransition__c myTransition = [Select id from Wrts_prcgvr__PhaseTransition__c];
        
        Map<String,Object> mapp = new Map<String,Object>();
        mapp.put('record',c);
        mapp.put('action',myTransition);
        mapp.put('method','Bozza');
        
        Test.startTest();
        
        HDT_UTL_ServiceCatalogOrFilter sc = new HDT_UTL_ServiceCatalogOrFilter();
        Boolean res = sc.evaluate(mapp);
        
        Test.stopTest();
        
        System.assertEquals(true, res, 'Not found in catalog');
        
        System.assertNotEquals(null, res, 'Result not returned correctly');
        
    }
    
    @isTest
	static void test2(){
        
        AccountStatementFilter__c acc = [Select id From AccountStatementFilter__c];
        Wrts_prcgvr__PhaseTransition__c myTransition = [Select id from Wrts_prcgvr__PhaseTransition__c];
        
        Map<String,Object> mapp = new Map<String,Object>();
        mapp.put('record',acc);
        mapp.put('action',myTransition);
        mapp.put('method','Bozza');
        
        Test.startTest();
        
        HDT_UTL_ServiceCatalogOrFilter sc = new HDT_UTL_ServiceCatalogOrFilter();
        Boolean res = sc.evaluate(mapp);
        
        Test.stopTest();
        
        System.assertEquals(true, res, 'Not found in catalog');
        
        System.assertNotEquals(null, res, 'Result not returned correctly');
        
    }
}