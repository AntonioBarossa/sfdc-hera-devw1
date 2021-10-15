@isTest
private class ConnectorEntityController_Test {
	@TestSetup
	static void makeData() {
		HDT_UTL_DataFactoryTst.pClickInstance();
	}

	@isTest
	static void run() {
		Test.startTest();

		ConnectorEntityController c = new ConnectorEntityController();
		String result;

		Map<String, Object> attachdata = new Map<String, Object>();
		Map<String, Object> message = new Map<String, Object> {
			'EVENT' => 'SwitchCrm',
			'CallType' => 'Outbound',
			'ConnectionID' => '123',
			'attachdata' => attachdata
		};

		// createActivity()
		result = ConnectorEntityController.createActivity(JSON.serialize(message));
		List<wrts_prcgvr__Activity__c> activityList = [SELECT Id, CrmChange__c FROM wrts_prcgvr__Activity__c];
		System.assertEquals(1, activityList.size(), 'FAIL - ATTIVITà PADRE NON GENERATA');
		wrts_prcgvr__Activity__c parentActivity = activityList[0];
		System.assert(parentActivity.CrmChange__c, 'FAIL - CRM CHANGE FLAG NON SETTATO');

		message.put('CallType', 'Inbound');
		result = ConnectorEntityController.createActivity(JSON.serialize(message));
		wrts_prcgvr__Activity__c childActivity = [SELECT Id, ParentActivity__c FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c != null];
		System.assertEquals(parentActivity.Id, childActivity.ParentActivity__c, 'FAIL - ATTIVITà FIGLIA NON AGGANCIATA A ATTIVITà PARENT');

		message.put('ErrorCode', 1);
		result = ConnectorEntityController.createActivity(JSON.serialize(message));
		System.assert(result.startsWith('ERROR: errorCode is not 0. Message'), 'FAIL - ERRORE NON SCATENATO');

		// closeActivity()
		attachdata.put('sf_activity_id', childActivity.Id);
		attachdata.put('operatorChange', 'true');
		ConnectorEntityController.closeActivity(JSON.serialize(message));
		
		childActivity = [SELECT Id, wrts_prcgvr__Status__c, OperatorChange__c FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c != null];
		System.assertEquals('Completed', childActivity.wrts_prcgvr__Status__c, 'FAIL - ATTIVITà NON CHIUSA');
		System.assert(childActivity.OperatorChange__c, 'FAIL - OPERATOR CHANGE FLAG NON SETTATO');
		
		String popDest = ConnectorEntityController.getPopDestination(childActivity.Id);
		System.assert(popDest != null, 'FAIL - DESTINATIONE POP NON GENERATA');

		String ou = ConnectorEntityController.ERCOmniUtilsPath;
		String iwss = ConnectorEntityController.ERCiwsscriptomniPath;
		String su = ConnectorEntityController.ERCsyncUtilsPath;

		Test.stopTest();
	}
}