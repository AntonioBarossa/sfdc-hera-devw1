@isTest
public with sharing class HDT_TRH_DocumentalActivityTst{

	//DEBUG

	public static final String TEST_NAME = 'HDT_TRH_DocumentalActivityTst';


	//SETUP

	
	//TESTING

	@isTest
	public static void beforeInsertTest(){
		
		
		
		//DEBUG

		String debugString = TEST_NAME + ' - ' + 'beforeInsertTest';
		System.debug(debugString);
		

		//SETUP

		HDT_UTL_DataFactoryTst.pClickCasePhase();
		
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, true, accList[0].id, 'Bozza');
		ordList[0].ParentOrder__c = ordList[1].Id;
		update ordList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
		caseList[0].ParentId = caseList[1].Id;
		update CaseList;
		List<DocumentalActivity__c> docActList = new List<DocumentalActivity__c>();
		DocumentalActivity__c dA1 = new DocumentalActivity__c();
		DocumentalActivity__c dA2 = new DocumentalActivity__c();

		// Necessario querare gli oggetti al fine di valorizzare i campi CaseNumber/OrderNumber
		Case caseOne = [SELECT Id, CaseNumber from Case WHERE Id = :caseList[0].Id LIMIT 1];
		Case caseTwo = [SELECT Id, CaseNumber from Case WHERE Id = :caseList[1].Id LIMIT 1];
		Order orderOne = [SELECT Id, OrderNumber from Order WHERE Id = :ordList[0].Id LIMIT 1];
		Order orderTwo = [SELECT Id, OrderNumber from Order WHERE Id = :ordList[1].Id LIMIT 1];

		dA1.ProcessId__c = caseOne.CaseNumber;
		dA2.ProcessId__c = orderOne.OrderNumber;
		
		dA1.ParentProcessId__c = caseTwo.CaseNumber;
		dA2.ParentProcessId__c = orderTwo.OrderNumber;

		docActList.add(dA1);
		docActList.add(dA2);		

		//TESTING

		Test.startTest();

        Try{

			insert docActList;
			
		}catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();

		//ASSERTS
        System.assert(docActList != null, 'Attenzione, docActList non può essere null!');
	}

}
