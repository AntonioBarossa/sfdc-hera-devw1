@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_LC_AccountSelectorController {
	@TestVisible
	private class HDT_UTL_Struct {
		@TestVisible Boolean isCall;
		@TestVisible String preFilter;
		@TestVisible String accountId;
		@TestVisible String contactId;
		@TestVisible String leadId;
		@TestVisible List<Account> accounts;
		@TestVisible List<Contact> contacts;
		@TestVisible List<Lead> leads;
	}

	private static final Map<String,Map<String,String>> fieldMappings = new Map<String,Map<String,String>>{
		'Case' => new Map<String,String> {
			'account' => 'accountId',
			'contact' => 'contactId'
		},
		'Interaction__c' => new Map<String,String> {
			'account' => 'Account__c',
			'contact' => 'Contact__c'
		},
		'wrts_prcgvr__Activity__c' => new Map<String,String> {
			'account' => 'Account__c',
			'contact' => 'Contact__c'
		}
	};

	@AuraEnabled
	public static String init(String recordId) {
		String sobjectType = getSobjectType(recordId);
		HDT_UTL_Struct result = new HDT_UTL_Struct();

		if(sobjectType == 'wrts_prcgvr__Activity__c') {
			wrts_prcgvr__Activity__c activity = [SELECT Id, Account__c, Contact__c, Lead__c, BPCode__c, ClientNumber__c, FiscalCode__c, VATNumber__c, Type__c, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
			
			result.isCall = activity.Type__c.contains('Chiamata');
			result.accountId = activity.Account__c;
			result.contactId = activity.Contact__c;
			result.leadId = activity.Lead__c;

			if(activity.wrts_prcgvr__Status__c != 'Chiusa') {
				if(String.isNotBlank(activity.BPCode__c)) {
					result.preFilter = activity.BPCode__c;
				} else if(String.isNotBlank(activity.FiscalCode__c)) {
					result.preFilter = activity.FiscalCode__c;
				} else if(String.isNotBlank(activity.VATNumber__c)) {
					result.preFilter = activity.VATNumber__c;
				} else if(String.isNotBlank(activity.ClientNumber__c)) {
					result.preFilter = activity.ClientNumber__c;
				}

				if(String.isBlank(activity.Account__c) && String.isNotBlank(activity.Contact__c)) {
					result.accounts = handleAccount(activity.Contact__c, activity.Id);
				} else if(String.isBlank(activity.Contact__c) && String.isBlank(activity.Lead__c) && String.isNotBlank(result.preFilter)) {
					result.contacts = getContacts(result.preFilter);
					result.leads = getLeads(result.preFilter);

					if(result.contacts.size() == 1 && result.leads.isEmpty()) {
						String contactId = result.contacts.get(0).Id;
						result.contactId = contactId;
						result.accounts = handleAccount(contactId, activity.Id);
						if(result.accounts.size() == 1) {
							result.accountId = result.accounts.get(0).Id;
						}
					} else if(result.contacts.isEmpty() && result.leads.size() == 1) {
						String leadId = result.leads.get(0).Id;
						handleLead(leadId, activity.Id);
						result.leadId = leadId;
					}
				}
			}
		} else {
			Map<String,String> fieldsMap = fieldMappings.get(sobjectType);
			SObject sobj = Database.query('SELECT Id,' + String.escapeSingleQuotes(fieldsMap.get('account')) + ',' + String.escapeSingleQuotes(fieldsMap.get('contact')) + ' FROM ' + String.escapeSingleQuotes(sobjectType) + ' WHERE Id =: recordId');
			result.accountId = (String) sobj.get(fieldsMap.get('account'));
			result.contactId = (String) sobj.get(fieldsMap.get('contact'));
		}
		return JSON.serialize(result);
	}

	@AuraEnabled
	public static String search(String queryString, String recordId) {
		HDT_UTL_Struct result = new HDT_UTL_Struct();
		if(queryString.isNumeric()) {
			if( queryString.startsWith('100') ){
				//BP
				result.accounts = getAccountByBPCode(queryString);
				result.contacts = getContactTitolare(result.accounts.get(0).Id);
			} else if( queryString.startsWith('3') && queryString.length() == 10 ){
				//mobilephone
				result=getContactsAndLeads(result, queryString,'MobilePhone', recordId);
			} else if ( queryString.length() == 10 ){
				//phone
				result=getContactsAndLeads(result, queryString,'Phone', recordId);
			} else if ( queryString.length() == 11 ){
				//P.IVA
				result=getContactsAndLeads(result, queryString,'VATNumber__c', recordId);
			}
		} else { //NO NUMERIC
			queryString = '%' + queryString + '%';
			if( queryString.contains('@') ){
				//mail
				result=getContactsAndLeads(result, queryString,'Email', recordId);
			} else if( queryString.length() == 18 ){
				//CF
				result=getContactsAndLeads(result, queryString,'FiscalCode__c', recordId);
			} else { //Name
				result=getContactsAndLeads(result, queryString,'Name', recordId);
			}
		}
		return JSON.serialize(result);
	}

	@AuraEnabled
	public static HDT_UTL_Struct getContactsAndLeads( HDT_UTL_Struct result, String queryString, String conditionField, String recordId ) {
		if(((Id) recordId).getSobjectType().getDescribe().getName() == 'wrts_prcgvr__Activity__c') {
			result.leads = getLeads(queryString, conditionField );
		}
		result.contacts = getContacts(queryString, conditionField );
		return result;
	}

	private static List<Account> getAccountByBpCode(String bpCode) {
		return [SELECT Id, Name, CustomerCode__c, FiscalCode__c, VATNumber__c, BillingAddressFormula__c 
				FROM Account WHERE CustomerCode__c LIKE :bpCode WITH SECURITY_ENFORCED];
	}

	private static List<Contact> getContactTitolare(String accountId) {
		return [SELECT Id, Name, Phone, MobilePhone, Email, FiscalCode__c, VATNumber__c 
				FROM Contact 
				WHERE Id IN 
					(SELECT ContactId FROM AccountContactRelation 
					WHERE AccountId = :accountId AND Roles = 'Titolare' AND isActive = true)
					WITH SECURITY_ENFORCED];
	}

	@AuraEnabled
	public static List<Contact> getContacts(String queryString, String conditionField ) {
		if(sObjectType.Contact.isAccessible()) {
			return Database.query(' SELECT Id, AccountId, Name, Phone, MobilePhone, Email, FiscalCode__c, VATNumber__c FROM Contact WHERE ' + String.escapeSingleQuotes(conditionField) + ' LIKE :queryString WITH SECURITY_ENFORCED ');
		} else {
			return null;
		}
	}

	@AuraEnabled
	public static List<Lead> getLeads(String queryString, String conditionField ) {
		if(sObjectType.Lead.isAccessible()) {
			return Database.query(' SELECT Id,Name,Phone,MobilePhone,Email,FiscalCode__c,VATNumber__c FROM Lead WHERE '+ String.escapeSingleQuotes(conditionField) +' LIKE :queryString WITH SECURITY_ENFORCED ');
		} else {
			return null;
		}
	}

	@AuraEnabled
	public static List<Contact> getContacts(String queryString) {
		return [
			SELECT
				Id,
				AccountId,
				Name,
				Phone,
				MobilePhone,
				Email,
				FiscalCode__c,
				VATNumber__c
			FROM Contact
			WHERE
				Name LIKE: queryString OR
				Phone LIKE: queryString OR
				MobilePhone LIKE: queryString OR
				Email LIKE: queryString OR
				FiscalCode__c LIKE: queryString OR
				VATNumber__c LIKE: queryString
			WITH SECURITY_ENFORCED
		];
	}

	@AuraEnabled
	public static List<Lead> getLeads(String queryString) {
		return [
			SELECT
				Id,
				Name,
				Phone,
				MobilePhone,
				Email,
				FiscalCode__c,
				VATNumber__c
			FROM Lead
			WHERE
				Name LIKE: queryString OR
				Phone LIKE: queryString OR
				MobilePhone LIKE: queryString OR
				Email LIKE: queryString OR
				FiscalCode__c LIKE: queryString OR
				VATNumber__c LIKE: queryString
			WITH SECURITY_ENFORCED
		];
	}

	@AuraEnabled
	public static void handleLead(String leadId, String recordId){
		updateRecord(recordId, null, null, leadId);
	}

	public static List<Account> handleAccount(Id contactId, String recordId) {
		List<Account> accounts = getAccounts(contactId);

		if(accounts.size() == 1) {
			updateRecord(recordId, contactId, accounts[0].Id, null);
		}

		return accounts;
	}

	@AuraEnabled
	public static String handleAccountSerialized(Id contactId, String recordId) {
		return JSON.serialize(handleAccount(contactId, recordId));
	}

	@AuraEnabled
	public static List<Account> getAccounts(String contactId) {
		return [SELECT Id, Name, CustomerCode__c, FiscalCode__c, VATNumber__c, BillingAddressFormula__c FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId) WITH SECURITY_ENFORCED];
	}

	@AuraEnabled
	public static void updateRecord(String recordId, String contactId, String accountId, String leadId) {
		String sobjectType = getSobjectType(recordId);
		Map<String,String> fieldsMap = fieldMappings.get(sobjectType);
		SObject sobj = instanceSobject(recordId);

		if(contactId != null) {
			sobj.put(fieldsMap.get('contact'), contactId);
		}
		if(accountId != null) {
			sobj.put(fieldsMap.get('account'), accountId);
		}
		if(leadId != null) {
			sobj.put('Lead__c', leadId);
		}
		List<SObject> objList = new List<SObject>();
		List <SObject> actList = handleInteractionActivity(recordId,contactId,accountId);
		objList.add(sobj);
		objList.addAll(actList);

		HDT_UTL_DatabaseService.updateSObject(objList);
	}
	private static List<Sobject> handleInteractionActivity(String recordId,String contactId, String accountId){
		String sobjectType = getSobjectType(recordId);
		List<wrts_prcgvr__Activity__c> actList = new List<wrts_prcgvr__Activity__c>();
		if(Schema.SObjectType.wrts_prcgvr__Activity__c.isAccessible()){
			actList = [SELECT Id,Account__c,Contact__c FROM wrts_prcgvr__Activity__c WHERE Interaction__c = :recordId WITH SECURITY_ENFORCED];
		}
		if(actList != null && !actList.isEmpty()){
			for(wrts_prcgvr__Activity__c act : actList){
				act.Account__c = accountId;
				act.Contact__c = contactId;
			}
		}
		return actList;
	}
	@AuraEnabled
	public static String reset(String recordId) {
		String sobjectType = getSobjectType(recordId);
		Map<String,String> fieldsMap = fieldMappings.get(sobjectType);
		SObject sobj = instanceSobject(recordId);
		sobj.put(fieldsMap.get('contact'), null);
		sobj.put(fieldsMap.get('account'), null);

		if(sobjectType == 'wrts_prcgvr__Activity__c') {
			sobj.put('Lead__c', null);
		}
		
		HDT_UTL_DatabaseService.updateSObject(sobj);

		return null;
	}

	private static String getSobjectType(String recordId) {
		return ((Id) recordId).getSobjectType().getDescribe().getName();
	}

	private static SObject instanceSobject(String recordId) {
		String sobjectType = getSobjectType(recordId);
		return Schema.getGlobalDescribe().get(sobjectType).newSObject(recordId);
	}
}
