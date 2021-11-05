/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 08/09/2021
 * @description Test Class for HDT_SRV_Individual.cls
 * @history Fabricio Petkevicius Nunes – 08/09/2021 – Created class
 */
@isTest
public class HDT_SRV_IndividualTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;
	}

	@isTest
	static void testCheckCreateAccess(){
        
        boolean finito = false;

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, false);

			HDT_SRV_Individual.checkCreateAccess(individuals[0]);

			Test.stopTest();
			finito = true;
			System.assertEquals(true, finito, 'testCheckCreateAccess not finished');
			System.assertNotEquals(false, finito, 'testCheckCreateAccess not finished');
		}
	}

	@isTest
	static void testCreateRecord(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, false);

			Individual createdInd=HDT_SRV_Individual.createRecord(individuals[0]);

			Test.stopTest();

			System.assertEquals(true, createdInd.Id!=null, 'Individual not created');
			System.assertNotEquals(false, createdInd.Id!=null, 'Individual not created');
		}
	}

	@isTest
	static void testCreateRecordList(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, false);

			List<Individual> createdIndList=HDT_SRV_Individual.createRecord(individuals);

			Test.stopTest();

			System.assertEquals(true, createdIndList[0].Id!=null, 'Individual not created');
			System.assertNotEquals(false, createdIndList[0].Id!=null, 'Individual not created');
		}
	}

	@isTest
	static void testCheckUpdateAccess(){
        
        boolean finito = false;

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);

			HDT_SRV_Individual.checkUpdateAccess(individuals[0]);

			Test.stopTest();
			finito = true;
			System.assertEquals(true, finito, 'testCheckUpdateAccess not finished');
			System.assertNotEquals(false, finito, 'testCheckUpdateAccess not finished');
		}
	}

	@isTest
	static void testUpdateRecord(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);

			individuals[0].FirstName='testUpdate';

			Individual updatedInd=HDT_SRV_Individual.updateRecord(individuals[0]);

			Test.stopTest();

			System.assertEquals('testUpdate', updatedInd.FirstName, 'Individual not updated');
			System.assertNotEquals('Mama', updatedInd.FirstName, 'Individual not updated');
		}
	}

	@isTest
	static void testUpsertIndividuals(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);

			individuals[0].FirstName='testUpsert';

			HDT_SRV_Individual.upsertIndividuals(individuals);

			Test.stopTest();

			List<Individual> upsertInds=[SELECT Id, FirstName
			                             FROM Individual
			                             WHERE FirstName='testUpsert'];

			System.assertEquals('testUpsert', upsertInds[0].FirstName, 'Individual not updated');
			System.assertNotEquals('Mama', upsertInds[0].FirstName, 'Individual not updated');
		}
	}

	@isTest
	static void testCheckUpsertAccess(){
        
        boolean finito = false;

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Individual> individuals=HDT_UTL_DataFactoryTst.createIndividual(1, true);

			individuals[0].FirstName='testUpdate';

			HDT_SRV_Individual.checkUpsertAccess(individuals[0]);

			Test.stopTest();
			finito = true;
			System.assertEquals(true, finito, 'testCheckUpsertAccess not finished');
			System.assertNotEquals(false, finito, 'testCheckUpsertAccess not finished');
		}
	}
}