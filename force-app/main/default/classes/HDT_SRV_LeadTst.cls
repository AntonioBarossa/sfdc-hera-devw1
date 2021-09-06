/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 06/09/2021
 * @description Test Class for HDT_SRV_Lead.cls
 * @history Fabricio Petkevicius Nunes – 06/00/2021 – Created class
 */
@isTest
public class HDT_SRV_LeadTst{
	@isTest
	static void testCheckAccessInit(){

		Test.startTest();

		HDT_SRV_Lead.checkAccessInit('CodIstat__c, AgeGroup__c', 'create');

		Test.stopTest();

		// Method Return is VOID
		// System.assertEquals('', '', '');
		// System.assertNotEquals('', '');
	}

	@isTest
	static void testCheckCreateAccess(){

		Test.startTest();

		List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);

		HDT_SRV_Lead.checkCreateAccess(leads[0]);

		Test.stopTest();

		// Method Return is VOID
		// System.assertEquals('', '', '');
		// System.assertNotEquals('', '');
	}

	@isTest
	static void testCreateRecord(){

		Test.startTest();

		List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);

		HDT_SRV_Lead.createRecord(leads[0]);

		Lead createdLead=[SELECT Id, FirstName
		                  FROM Lead
		                  WHERE FirstName='FirstNameTest0'];

		Test.stopTest();

		System.assertEquals(false, createdLead.Id==null, 'Lead not created');
		System.assertNotEquals(true, createdLead.Id==null);
	}

	@isTest
	static void testCheckUpdateAccess(){

		Test.startTest();

		List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, false);

		HDT_SRV_Lead.checkUpdateAccess(leads[0]);

		Test.stopTest();

		// Method Return is VOID
		// System.assertEquals('', '', '');
		// System.assertNotEquals('', '');
	}

	@isTest
	static void testUpdateRecord(){

		Test.startTest();

		List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, true);

		leads[0].MobilePhone='1234567906';

		HDT_SRV_Lead.updateRecord(leads[0]);

		Lead updatedLead=[SELECT Id, MobilePhone
		                  FROM Lead
		                  WHERE MobilePhone='1234567906'];

		Test.stopTest();

		System.assertEquals(true, updatedLead.MobilePhone=='1234567906', 'Lead not updated');
		System.assertNotEquals(true, updatedLead.MobilePhone==null);
	}
}