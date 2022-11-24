@isTest
public with sharing class HDT_LC_AgentMatrixSearchToolContrTst{

	@testSetup
	static void setup(){

        List<AssignmentRule__c> myAssignmentRule = HDT_UTL_DataFactoryTst.createAssignmentRule(1, true, 1, 'Gestione dati discordanti');

		List<AgentMatrix__c> myAgentMatrixList = HDT_UTL_DataFactoryTst.createAgentMatrix(1, false, 'Sportello');
        myAgentMatrixList[0].AgentFirstName__c = 'Mario';
        myAgentMatrixList[0].AgentLastName__c = 'Rossi';
        myAgentMatrixList[0].AgentCode__c = 'AG055TLS001';
        myAgentMatrixList[0].AgencyName__c = 'Conduent (ex Xerox) da Maggio 2017';
        myAgentMatrixList[0].AgencyCode__c = 'AG055';
        insert myAgentMatrixList;



	}

	@isTest
	public static void getCurrentAgentTest(){

        AssignmentRule__c myRule = [Select Id, SalesAgency__c from AssignmentRule__c LIMIT 1];
        AgentMatrix__c myAgentMatrix = [Select id, AgentFirstName__c, AgentLastName__c, AgentCode__c, AgencyName__c, AgencyCode__c FROM AgentMatrix__c LIMIT 1];

        myRule.SalesAgency__c = myAgentMatrix.AgencyCode__c;
        Update myRule;

		Test.startTest();

		List<AggregateResult> myMatrix  = HDT_LC_AgentMatrixSearchToolController.getCurrentAgent(myRule.Id);
		
        System.assert(myMatrix != null, 'La AgentMatrix non esiste');

        /*Delete myAgentMatrix;
        myMatrix = HDT_LC_AgentMatrixSearchToolController.getCurrentAgent(myRule.Id);
        System.assert(myMatrix != null, 'La AgentMatrix non esiste');

        myRule.SalesAgency__c = null;
        Update myRule;
		myMatrix  = HDT_LC_AgentMatrixSearchToolController.getCurrentAgent(myRule.Id);		
        System.assert(myMatrix == null, 'La AgentMatrix esiste');*/


		Test.stopTest();

	}

    @isTest
	public static void getAgentsTest(){

        String myString = 'Rossi';
		Test.startTest();		

		List<AgentMatrix__c> myAgentMatrixList  = HDT_LC_AgentMatrixSearchToolController.getAgents(myString);
		
        System.assert(myAgentMatrixList != null, 'La AgentMatrixList non esiste');

		Test.stopTest();

	}
    @isTest
	public static void getAgentsGroupedTest(){

        String myString = 'Rossi';
		Test.startTest();		

		List<AggregateResult> myAgentMatrixList  = HDT_LC_AgentMatrixSearchToolController.getAgentsGrouped(myString);
		
        System.assert(myAgentMatrixList != null, 'La AgentMatrixList non esiste');

		Test.stopTest();

	}
    @isTest
	public static void updateRuleTest(){

        AssignmentRule__c myRule = [Select Id, SalesAgency__c from AssignmentRule__c LIMIT 1];

        Test.startTest();		

		String result = HDT_LC_AgentMatrixSearchToolController.updateRule(myRule.Id, 'AG055');
        System.assert(result == null, 'Update Rule non riuscito');

		Test.stopTest();

	}

}