global with sharing class ConnectorEntityController {
	public ConnectorEntityController() {}

	private class AttachData {
		String target_crm;
		String sf_activity_id;
		String sb_activity_id;
	}

	@RemoteAction
	global static String createActivity(String jsonMessage) {
		Map<String,Object> message = (Map<String,Object>) JSON.deserializeUntyped(jsonMessage);
		AttachData attachdata = (AttachData) JSON.deserialize((String) message.get('attachdata'), attachdata.class);

		if(message.get('ErrorCode') != '0') {
			return 'Error: ' + message.get('ErrorMessage');
		}

		RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_Chiamata'];
		wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
			RecordTypeId = recordType.Id,
			Type__c = 'Chiamata',
			wrts_prcgvr__Status__c = 'In Progress',
			ActivityStartTime__c = DateTime.now(),
			CallStartTime__c = DateTime.now(),
			ConnectionID__c = (String) message.get('ConnectionID'),
			Subtype__c = (String) message.get('CallType')
		);

		switch on (String) message.get('CallType') {
			when 'Outbound' {
				activity.CallCenterNumber__c = (String) message.get('ANI');
				activity.ClientNumber__c = (String) message.get('DNIS');
			}
			when 'Inbound' {
				activity.CallCenterNumber__c = (String) message.get('DNIS');
				activity.ClientNumber__c = (String) message.get('ANI');
			}
		}

		for(wrts_prcgvr__Activity__c a : [SELECT Id FROM wrts_prcgvr__Activity__c WHERE ConnectionID__c =: activity.ConnectionID__c ORDER BY CreatedDate DESC LIMIT 1]) {
			activity.ParentActivity__c = a.Id;
		}

		Map<String,String> result = new Map<String,String>();
		List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Phone =: activity.ClientNumber__c OR MobilePhone =: activity.ClientNumber__c];
		if(contacts.size() == 1) {
			Contact contact = contact[0];
			activity.Contact__c = contact.Id;
			result.put('contactId', contact.Id);
			List<AccountContactRelation> relations = [SELECT Id FROM AccountContactRelation WHERE ContactId =: contact.Id];
			if(relations.size() == 1) {
				activity.Account__c = contact.AccountId;
				result.put('accountId', contact.AccountId);
			}
		}

		insert activity;
		result.put('activityId', activity.Id);
		
		return JSON.serialize(result);
	}

	@RemoteAction
	global static String closeActivity(String jsonMessage, Boolean crmChange, Boolean operatorChange) {
		Map<String,Object> message = (Map<String,Object>) JSON.deserializeUntyped(jsonMessage);
		AttachData attachdata = (AttachData) JSON.deserialize((String) message.get('attachdata'), attachdata.class);

		wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(
			Id = attachdata.sf_activity_id,
			wrts_prcgvr__Status__c = 'Completed',
			ActivityEndTime__c = Datetime.now(),
			CallEndTime__c = Datetime.now(),
			ActivityDuration__c = (Decimal) message.get('Duration'),
			CallDuration__c = (Decimal) message.get('Duration'),
			WaitingTime__c = 0, // WIP
			CrmChange__c = crmChange,
			OperatorChange__c = operatorChange,
			BPCode__c = ''
		);

		try {
			update activity;
		} catch (Exception e) {
			return 'ERROR: ' + e.getMessage() + ' ' + e.getCause();
		}

		return '0';
	}
	
	@RemoteAction
	global static Task createTask(Task task,String field, String value) {
		
		try{        
			List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + field + ' = \'' + value + '\'');
			System.debug('contacts found : ' + contacts);
			if ( contacts.size() == 1 ){
				task.WhoId = contacts.get(0).Id;
			} 
			} catch(Exception e){
			System.debug('Error in finding contact ' + e);     
		}

		try{           
			Database.SaveResult sr =  Database.insert(task);
				System.debug('save result : ' + sr);   
				return task;
			} catch(Exception e){
			System.debug('Error in insert ' + e);
		
		}
		return null;
	}

	@RemoteAction
	global static Case createCase(Case obj,String field, String value) {
		
		try{        
			List<Contact> contacts = Database.query('Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where ' + field + ' = \'' + value + '\'');
			System.debug('contacts found : ' + contacts);
			if ( contacts.size() == 1 ){
				obj.ContactId = contacts.get(0).Id;
			} 
			} catch(Exception e){
			System.debug('Error in finding contact ' + e);     
		}

		try{           
			Database.SaveResult sr =  Database.insert(obj);
				System.debug('save result : ' + sr);   
				return obj;
			} catch(Exception e){
			System.debug('Error in insert ' + e);
		
		}
		return null;
	}

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


	public static String GetResourceURL(String namespace,String resourceName){
	List<StaticResource> resourceList= namespace != null ? 
	[SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName AND NamespacePrefix = :namespace] : 
	[SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName] ;
		if(resourceList.size() == 1){
			String nm = resourceList[0].NamespacePrefix;
		return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (nm != null && nm != '' ? nm + '__' : '') + resourceName; 
		}
		return '';
	}
}