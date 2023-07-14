@SuppressWarnings('PMD.MethodNamingConventions, PMD.LocalVariableNamingConventions, PMD.ClassNamingConventions')

/**
* @author Elvin Iluca
* @date 21/10/2022
* @description Test Class for ConnectorEntityController.cls
* @history Elvin Iluca – 21/10/2022 – Class refactoring
*/

@isTest
private class ConnectorEntityController_Test {
	
	//DATA
	private static Map<String, Object> attachdata = new Map<String, Object>();
	private static Map<String, Object> message = new Map<String, Object> {
		'EVENT' => 'SwitchCrm',
		'CallType' => 'Outbound',
		'ConnectionID' => '123'
	}; 
	
	/**
	* @author Elvin Iluca
	* @date 21/10/2022
	* @description Test Class for ConnectorEntityController.cls
	* @history Elvin Iluca – 21/10/2022 – makeData method refactoring
	*/

	@TestSetup
	static void makeData() {
		HDT_UTL_DataFactoryTst.pClickInstance();
		ConnectorEntityController c = new ConnectorEntityController();

		List<Account> temp = HDT_UTL_DataFactoryTst.createAccountPartner(1,true,'test');
		List<wrts_prcgvr__Activity__c> tempActivitys = HDT_UTL_DataFactoryTst.createActivityCustom(2, true, temp[0].id);
		tempActivitys[0].ParentActivity__c = tempActivitys[1].Id;
		tempActivitys[0].wrts_prcgvr__Description__c = 'Test'; 
		tempActivitys[1].wrts_prcgvr__Description__c = 'Test'; 
		update tempActivitys;

	}

	/**
	* @author Elvin Iluca
	* @date 21/10/2022
	* @description Test Class for ConnectorEntityController.cls
	* @history Elvin Iluca – 21/10/2022 – Created test method for createActivity()
	*/
    @isTest
    static void createActivityTstException () {
		String ret;

		Test.startTest();
		
		ret = ConnectorEntityController.createActivity(JSON.serialize(message));
		System.assertEquals('ERROR: Attempt to de-reference a null object', ret, 'FAIL - no exception thrown');
		Test.stopTest();
	}


	/**
	* @author Elvin Iluca
	* @date 21/10/2022
	* @description Test Class for ConnectorEntityController.cls
	* @history Elvin Iluca – 21/10/2022 – Created test method for createActivity()
	*/
    @isTest
    static void createActivityTst () {
		String ret;
		message.put('attachdata',attachdata);

		Test.startTest();
		ret = ConnectorEntityController.createActivity(JSON.serialize(message));
		Test.stopTest();

		List<wrts_prcgvr__Activity__c> activityList = [SELECT Id, CrmChange__c FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Description__c != 'Test'];
		System.assertEquals(1, activityList.size(), 'FAIL - ATTIVITà PADRE NON GENERATA');
		wrts_prcgvr__Activity__c parentActivity = activityList[0];
		System.assert(parentActivity.CrmChange__c, 'FAIL - CRM CHANGE FLAG NON SETTATO');

	}

	/**
	* @author Elvin Iluca
	* @date 21/10/2022
	* @description Test Class for ConnectorEntityController.cls
	* @history Elvin Iluca – 21/10/2022 – Created test method for createActivity()
	*/
    @isTest
    static void createActivityTstInbound () {
		String ret;

		message.put('attachdata',attachdata);
		message.put('CallType', 'Inbound');

		Test.startTest();
		ret = ConnectorEntityController.createActivity(JSON.serialize(message));
		Test.stopTest();

		List<wrts_prcgvr__Activity__c> activityList = [SELECT Id, CrmChange__c FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Description__c = 'Test' AND ParentActivity__c = null];

		wrts_prcgvr__Activity__c parentActivity = activityList[0];
		
		wrts_prcgvr__Activity__c childActivity = [SELECT Id, ParentActivity__c FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c != null AND wrts_prcgvr__Description__c = 'Test'];
		System.assertEquals(parentActivity.Id, childActivity.ParentActivity__c, 'FAIL - ATTIVITà FIGLIA NON AGGANCIATA A ATTIVITà PARENT');
		
	}

	/**
	* @author Elvin Iluca
	* @date 21/10/2022
	* @description Test Class for ConnectorEntityController.cls
	* @history Elvin Iluca – 21/10/2022 – Created test method for createActivity()
	*/
    @isTest
    static void createActivityTstErrorCode () {
		String ret;

		message.put('attachdata',attachdata);
		message.put('ErrorCode', 1);

		Test.startTest();
		ret = ConnectorEntityController.createActivity(JSON.serialize(message));
		Test.stopTest();
		System.assert(ret.startsWith('ERROR: errorCode is not 0. Message'), 'FAIL - ERRORE NON SCATENATO');

	}



	/**
	* @author Elvin Iluca
	* @date 21/10/2022
	* @description Test Class for ConnectorEntityController.cls
	* @history Elvin Iluca – 21/10/2022 – Created test method for closeActivity()
	*/
    @isTest
    static void closeActivityTst () {

		String ret;

		wrts_prcgvr__Activity__c childActivity = [SELECT Id, wrts_prcgvr__Status__c, OperatorChange__c FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c != null];
		
		attachdata.put('sf_activity_id', childActivity.Id);
		attachdata.put('operatorChange', 'true');

		Test.startTest();

		ret = ConnectorEntityController.closeActivity(JSON.serialize(message));
		System.assertEquals('ERROR: Attempt to de-reference a null object', ret, 'FAIL - no exception thrown');

		message.put('attachdata',attachdata);
		ConnectorEntityController.closeActivity(JSON.serialize(message));

		Test.stopTest();
		
		childActivity = [SELECT Id, wrts_prcgvr__Status__c, OperatorChange__c FROM wrts_prcgvr__Activity__c WHERE ParentActivity__c != null];
		System.assertEquals('Chiusa', childActivity.wrts_prcgvr__Status__c, 'FAIL - ATTIVITà NON CHIUSA');
		System.assert(childActivity.OperatorChange__c, 'FAIL - OPERATOR CHANGE FLAG NON SETTATO');
		
		String popDest = ConnectorEntityController.getPopDestination(childActivity.Id);
		System.assert(popDest != null, 'FAIL - DESTINATIONE POP NON GENERATA');
	}

	/**
	* @author Elvin Iluca
	* @date 21/10/2022
	* @description Test Class for ConnectorEntityController.cls
	* @history Elvin Iluca – 21/10/2022 – Created test method for GetResourceURL()
	*/
    @isTest
    static void getResourceURLTst () {
		Test.startTest();
		String test1 = ConnectorEntityController.ERCOmniUtilsPath;
		String test2 = ConnectorEntityController.ERCiwsscriptomniPath;
		String test3 = ConnectorEntityController.ERCsyncUtilsPath;
		Test.stopTest();
		System.assert(String.isEmpty(test1), 'Fail to retrive the resource');
		System.assert(String.isEmpty(test2), 'Fail to retrive the resource');
		System.assert(String.isEmpty(test3), 'Fail to retrive the resource');
	}

}