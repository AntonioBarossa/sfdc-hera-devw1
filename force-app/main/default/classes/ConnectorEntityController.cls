global with sharing class ConnectorEntityController {
	public ConnectorEntityController() {}

	@RemoteAction
	global static String createActivity(String jsonMessage) {
		Map<String,Object> message = (Map<String,Object>) JSON.deserializeUntyped(jsonMessage);
		Map<String,Object> attachdata = (Map<String,Object>) message.get('attachdata');
		Map<String,String> result = new Map<String,String>();
		wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
		HDT_SRV_LogService logs = new HDT_SRV_LogService('ConnectorEntityController');

		try {
			if((Integer) message.get('ErrorCode') > 0) {
				
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			list <OrgWideEmailAddress> orgWideAddress = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address' WITH SECURITY_ENFORCED LIMIT 1];
			mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);

                mail.setToAddresses(new String[]{'danilo.penna@nttdata.com'});
                mail.setSubject('Create Activity Exception Message');
                String body='JSON Exception messagge: ERROR: errorCode is not 0. Message: ' + JSON.serialize(message) + '   ' +jsonMessage ;
                mail.setPlainTextBody (body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
				return 'ERROR: errorCode is not 0. Message: ' + JSON.serialize(message);
			}

			RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_Call'];
			activity.RecordTypeId = recordType.Id;
			activity.wrts_prcgvr__Status__c = 'In Progress';
			activity.CallStartTime__c = DateTime.now();
			activity.ConnectionID__c = (String) message.get('ConnectionID');
			activity.Place__c = (String) message.get('Place');
			activity.BPCode__c = (String) attachdata.get('ivr_CODICE_CLIENTE');
			activity.IwsDemand__c = (String) attachdata.get('ESIGENZA_IWS');
			activity.CallCenterNumber__c = (String) attachdata.get('NUMERO_VERDE');

			handleCrmChangeFlag(message, activity);

			switch on (String) message.get('CallType') {
				when 'Outbound' {
					activity.Type__c = 'Chiamata Outbound';
					// activity.CallCenterNumber__c = (String) message.get('ANI');
					activity.ClientNumber__c = message.get('DNIS') != null ? ((String) message.get('DNIS')).removeStart('0') : null;
					//ripristinato removeStart('0') solo per outbound
					//AF RIMOSSA ISTRUZIONE removeStart('0') in quanto rimuovendo lo 0 non veniva fatto il match con i numeri presenti in SFDC
					//activity.ClientNumber__c = message.get('DNIS') != null ? (String) message.get('DNIS') : null;
				}
				when 'Inbound' {
					activity.Type__c = 'Chiamata Inbound';
					// activity.CallCenterNumber__c = (String) message.get('DNIS');
					//activity.ClientNumber__c = message.get('ANI') != null ? ((String) message.get('ANI')).removeStart('0') : null;
					
					//AF RIMOSSA ISTRUZIONE removeStart('0') in quanto rimuovendo lo 0 non veniva fatto il match con i numeri presenti in SFDC
					activity.ClientNumber__c = message.get('ANI') != null ? (String) message.get('ANI') : null;
				}
			}

			for(wrts_prcgvr__Activity__c a : [SELECT Id FROM wrts_prcgvr__Activity__c WHERE ConnectionID__c =: activity.ConnectionID__c ORDER BY CreatedDate DESC LIMIT 1]) {
				activity.ParentActivity__c = a.Id;
			}

			// ACCOUNT/CONTACT/LEAD SELECTION NOW FLOW-HANDLED
			// List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Phone =: activity.ClientNumber__c OR MobilePhone =: activity.ClientNumber__c];
			// if(contacts.size() == 1) {
			// 	Contact contact = contacts[0];
			// 	activity.Contact__c = contact.Id;
			// 	result.put('contactId', contact.Id);
			// 	List<AccountContactRelation> relations = [SELECT Id FROM AccountContactRelation WHERE ContactId =: contact.Id];
			// 	if(relations.size() == 1) {
			// 		activity.Account__c = contact.AccountId;
			// 		result.put('accountId', contact.AccountId);
			// 	}
			// }

			insert activity;

			activity = [SELECT Id, Account__c, Contact__c, Lead__c FROM wrts_prcgvr__Activity__c WHERE Id =: activity.Id];

			result.put('activityId', activity.Id);
			result.put('accountId', activity.Account__c);
			result.put('contactId', activity.Contact__c);
			result.put('leadId', activity.Lead__c);
		} catch (Exception e) {
			logs.insertSingleLog('ConnectorEntityController', 'createActivity', jsonMessage, null,e.getMessage()+' '+e.getStackTraceString()+' Activity : ' + JSON.serialize(activity), activity.Id, null, null);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			list <OrgWideEmailAddress> orgWideAddress = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address' WITH SECURITY_ENFORCED LIMIT 1];
			mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);

			mail.setToAddresses(new String[]{'danilo.penna@nttdata.com'});
			mail.setSubject('Create Activity Exception Message');
			String body='Exception messagge: ERROR: ' + e.getMessage() + '   ' +jsonMessage;
			mail.setPlainTextBody (body);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			
			return 'ERROR: ' + e.getMessage();
		}
		system.debug('Result Krist: '+result);
		return JSON.serialize(result);
	}

	@RemoteAction
	global static String closeActivity(String jsonMessage) {
		Map<String,Object> message = (Map<String,Object>) JSON.deserializeUntyped(jsonMessage);
		Map<String,Object> attachdata = (Map<String,Object>) message.get('attachdata');
		HDT_SRV_LogService logs = new HDT_SRV_LogService('ConnectorEntityController');
		System.debug('#message ' +message);
		System.debug('#message JSON ' + jsonMessage);
		System.debug('#attachdata JSON ' + json.serialize(attachdata));
		System.debug('#attachdata ' + attachdata);
		wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
			wrts_prcgvr__Status__c = 'Chiusa',
			ActivityEndTime__c = Datetime.now(),
			CallEndTime__c = Datetime.now(),
			WaitingTime__c = 0 // WIP
		);
		try {
			Decimal callDuration = (Decimal) message.get('Duration');
			callDuration = callDuration != null? callDuration/60:0;
			activity.Id = (String) attachdata.get('sf_activity_id');
			activity.CallDuration__c = callDuration;
			activity.RecordingLink__c = (String) attachdata.get('URLREC');


			handleCrmChangeFlag(message, activity);

			String operatorChange = (String) attachdata.get('operatorChange');
			if(operatorChange != null && operatorChange.toLowerCase() == 'true') {
				activity.OperatorChange__c = true;
			}

			update activity;
		} catch (Exception e) {
			// WIP
			logs.insertSingleLog('ConnectorEntityController', 'closeActivity', jsonMessage, null,e.getStackTraceString() + ' '+ e.getMessage() +' Activity: '+ JSON.serialize(activity), activity.Id, null, null);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			list <OrgWideEmailAddress> orgWideAddress = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address' WITH SECURITY_ENFORCED LIMIT 1];
			mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);

			mail.setToAddresses(new String[]{'danilo.penna@nttdata.com'});
			mail.setSubject('Close Activity Exception Message');
			String body='Exception messagge: ERROR: ' + e.getMessage() + '   ' +jsonMessage;
			mail.setPlainTextBody (body);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

			return 'ERROR: ' + e.getMessage();
		}

		return null;
	}

	private static void handleCrmChangeFlag(Map<String,Object> message, wrts_prcgvr__Activity__c activity) {
		if(message.get('EVENT') == 'SwitchCrm') {
			activity.CrmChange__c = true;
		}
	}

	@RemoteAction
	global static String getPopDestination(String activityId) {
		wrts_prcgvr__Activity__c activity = [SELECT Id, Account__c FROM wrts_prcgvr__Activity__c WHERE Id =: activityId];
		return String.isBlank(activity.Account__c) ? activityId : activity.Account__c;
	}
	
	// NOT USED
	// @RemoteAction
	// global static Task createTask(Task task,String field, String value) {
		
	// 	try{        
	// 		List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + field + ' = \'' + value + '\'');
	// 		System.debug('contacts found : ' + contacts);
	// 		if ( contacts.size() == 1 ){
	// 			task.WhoId = contacts.get(0).Id;
	// 		} 
	// 		} catch(Exception e){
	// 		System.debug('Error in finding contact ' + e);     
	// 	}

	// 	try{           
	// 		Database.SaveResult sr =  Database.insert(task);
	// 			System.debug('save result : ' + sr);   
	// 			return task;
	// 		} catch(Exception e){
	// 		System.debug('Error in insert ' + e);
		
	// 	}
	// 	return null;
	// }

	// NOT USED
	// @RemoteAction
	// global static Case createCase(Case obj,String field, String value) {
		
	// 	try{        
	// 		List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + field + ' = \'' + value + '\'');
	// 		System.debug('contacts found : ' + contacts);
	// 		if ( contacts.size() == 1 ){
	// 			obj.ContactId = contacts.get(0).Id;
	// 		} 
	// 		} catch(Exception e){
	// 		System.debug('Error in finding contact ' + e);     
	// 	}

	// 	try{           
	// 		Database.SaveResult sr =  Database.insert(obj);
	// 			System.debug('save result : ' + sr);   
	// 			return obj;
	// 		} catch(Exception e){
	// 		System.debug('Error in insert ' + e);
		
	// 	}
	// 	return null;
	// }

	@RemoteAction
	global static String ERCOmniUtilsPath {
		get {
			return GetResourceURL('softphoneerc','omniUtils');
		}
	}

	@RemoteAction
	global static String ERCiwsscriptomniPath {
		get {
			return GetResourceURL(null,'iwsscript_omni');
		}
	}

	@RemoteAction
	global static String ERCsyncUtilsPath {
		get {
			return GetResourceURL(null,'syncUtils');
		}
	}

	public static String GetResourceURL(String namespace,String resourceName) {
		List<StaticResource> resourceList = namespace != null ? 
		[SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName AND NamespacePrefix = :namespace] : 
		[SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
		if(resourceList.size() == 1) {
			String nm = resourceList[0].NamespacePrefix;
			return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (nm != null && nm != '' ? nm + '__' : '') + resourceName; 
		}
		return '';
	}
}