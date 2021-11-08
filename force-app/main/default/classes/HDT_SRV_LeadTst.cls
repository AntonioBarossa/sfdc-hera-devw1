/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 06/09/2021
 * @description Test Class for HDT_SRV_Lead.cls
 * @history Fabricio Petkevicius Nunes – 06/00/2021 – Created class
 */
@isTest
public class HDT_SRV_LeadTst{
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

			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);

			HDT_SRV_Lead.checkCreateAccess(leads[0]);

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

			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);

			HDT_SRV_Lead.createRecord(leads[0]);

			Lead createdLead=[SELECT Id, FirstName
			                  FROM Lead
			                  WHERE FirstName='FirstNameTest0'];

			Test.stopTest();

			System.assertEquals(false, createdLead.Id==null, 'Lead not created');
			System.assertNotEquals(true, createdLead.Id==null, 'Lead not created');
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

			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);

			HDT_SRV_Lead.checkUpdateAccess(leads[0]);

			Test.stopTest();
            finito = true;
			System.assertEquals(true, finito, 'testCheckCreateAccess not finished');
			System.assertNotEquals(false, finito, 'testCheckCreateAccess not finished');
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

			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, true);

			leads[0].MobilePhone='1234567906';

			HDT_SRV_Lead.updateRecord(leads[0]);

			Lead updatedLead=[SELECT Id, MobilePhone
			                  FROM Lead
			                  WHERE MobilePhone='1234567906'];

			Test.stopTest();

			System.assertEquals(true, updatedLead.MobilePhone=='1234567906', 'Lead not updated');
			System.assertNotEquals(true, updatedLead.MobilePhone==null, 'Lead not updated');
		}
	}
}