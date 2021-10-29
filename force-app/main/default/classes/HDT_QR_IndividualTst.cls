/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 14/09/2021
 * @description Test Class for HDT_QR_Individual.cls
 * @history Fabricio Petkevicius Nunes – 14/09/2021 – Created class
 */
@isTest
public class HDT_QR_IndividualTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_QR_Individual individualQr=new HDT_QR_Individual();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){
			List<Individual> individuals;
			individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);
		}
	}

	@isTest
	public static void testGetRecordById(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Individual> tIndividual=[SELECT Id, FirstName
			                              FROM Individual
			                              WHERE FirstName='Mama'];

			Individual tInd=individualQr.getRecordById(tIndividual[0].Id, 'FirstName, LastName');

			test.stopTest();

			System.assertEquals(true, tInd.Id!=null, 'Individual not found');
			System.assertNotEquals(false, tInd.Id!=null, 'value of parameter is not matching');
		}
	}
}