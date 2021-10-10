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

			List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].Id, 'Attiva');
			sales[0].Name='Vendita Fabiana Federici 313';
			sales[0].CurrentStep__c=1;
			insert sales;

			List<wrts_prcgvr__Activity__c> custActivity=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accList[0].Id);
			custActivity[0].Type__c='Approvazione Offerte';
			custActivity[0].Status__c='Creata';
			custActivity[0].Sale__c=sales[0].Id;
			insert custActivity;
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
}