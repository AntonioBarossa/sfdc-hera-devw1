/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 16/09/2021
 * @description Test Class for HDT_QR_Activity.cls
 * @history Fabricio Petkevicius Nunes – 16/09/2021 – Created class
 */
@isTest
public class HDT_QR_ActivityTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_QR_Activity activQr=new HDT_QR_Activity();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){
			HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
			List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].Id, 'Attiva');
			sales[0].Name='Vendita Fabiana Federici 313';
			sales[0].CurrentStep__c=1;
			insert sales;

			List<wrts_prcgvr__Activity__c> custActivity=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
			custActivity[0].Type__c='Approvazione Offerte';
			custActivity[0].wrts_prcgvr__Status__c='Aperta';
			custActivity[0].Sale__c=sales[0].Id;
			insert custActivity;

			//START MODIFICA marco.arci@webresults.it
			list<Case> listFakeCases = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].Id, null, null, null, null);
            insert listFakeCases;

			List<Order> listFakeOrders =  HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
            insert listFakeOrders;

			List<wrts_prcgvr__Activity__c> testActivityCase=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
			testActivityCase[0].Type__c='Aprire Variazione';
			testActivityCase[0].wrts_prcgvr__Status__c='Aperta';
			testActivityCase[0].Case__c=listFakeCases[0].Id;
			insert testActivityCase;

			List<wrts_prcgvr__Activity__c> testActivityOrder=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
			testActivityOrder[0].Type__c='Aprire Cessazione';
			testActivityOrder[0].wrts_prcgvr__Status__c='Aperta';
			testActivityOrder[0].Order__c=listFakeOrders[0].Id;
			insert testActivityOrder;
			//END MODIFICA marco.arci@webresults.it
		}
	}

	@isTest
	public static void testGetLastActivity(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAccs=[SELECT Id, Name
			                     FROM Account
			                     WHERE Name='test account0'];

			List<Sale__c> tSale=[SELECT Id, Name
			                     FROM Sale__c
			                     WHERE Name='Vendita Fabiana Federici 313'];

			wrts_prcgvr__Activity__c tActivity=activQr.getLastActivity(tAccs[0].id, tSale[0]);

			test.stopTest();

			System.assertEquals(true, tActivity.Id!=null, 'Activity not found');
			System.assertNotEquals(false, tActivity.Id!=null, 'Activity not found');
		}
	}

	
@isTest
	public static void testGetActivityFromIdList(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAccs=[SELECT Id, Name
			                     FROM Account
			                     WHERE Name='test account0'];

			List<Sale__c> tSale=[SELECT Id, Name
			                     FROM Sale__c
			                     WHERE Name='Vendita Fabiana Federici 313'];

			wrts_prcgvr__Activity__c tActivity=activQr.getLastActivity(tAccs[0].id, tSale[0]);
			Set<String> sAct = new Set<String>();
            sAct.add(String.valueOf(tActivity.Id));
            List<wrts_prcgvr__Activity__c> tActivityL = new List<wrts_prcgvr__Activity__c>();
            tActivityL = HDT_QR_Activity.getActivityFromIdList(sAct);
			test.stopTest();

			System.assertEquals(true, tActivityL[0].Id!=null, 'Activity not found');
			System.assertNotEquals(false, tActivityL[0].Id!=null, 'Activity not found');
		}
	}
//START MODIFICA marco.arci@webresults.it
	@isTest
	public static void testgetActivityFromTypeList(){
		List<wrts_prcgvr__Activity__c> resultListActCase = new List<wrts_prcgvr__Activity__c>();
		List<wrts_prcgvr__Activity__c> resultListActOrder = new List<wrts_prcgvr__Activity__c>();
		String caseId = [SELECT Id FROM Case].Id;
		Test.startTest();
		resultListActCase = HDT_QR_Activity.getActivityFromTypeList(new List<String>{caseId}, new Set<String>{'Aprire Variazione'});

		system.assertEquals(1, resultListActCase.size());

		String orderId = [SELECT Id FROM Order].Id;
		resultListActOrder = HDT_QR_Activity.getActivityFromTypeList(new List<String>{orderId}, new Set<String>{'Aprire Cessazione'});
		Test.stopTest();
		system.assertEquals(1, resultListActOrder.size());
	}
//END MODIFICA marco.arci@webresults.it
}