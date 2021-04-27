public with sharing class HDT_LC_AccountSelectorController {
	private class Struct {
		String accountId;
		String contactId;
		List<Account> accounts;
		List<Contact> contacts;
	}
	
	@AuraEnabled
	public static String init(String recordId) {
		wrts_prcgvr__Activity__c activity = [SELECT Id, Account__c, Contact__c, ClientNumber__c FROM wrts_prcgvr__Activity__c WHERE Id =: recordId];
		
		Struct result = new Struct();
		result.accountId = activity.Account__c;
		result.contactId = activity.Contact__c;

		if(String.isBlank(activity.Contact__c)) {
			result.contacts = getContacts(activity.ClientNumber__c);
		}
		if(String.isBlank(activity.Account__c)) {
			result.accounts = handleAccount(activity.Contact__c, activity.Id);
		}

		return JSON.serialize(result);
	}

	@AuraEnabled
	public static List<Contact> getContacts(String queryString) {
		return [SELECT Id, AccountId, Name, Phone, MobilePhone, Email FROM Contact WHERE Name =: queryString OR Phone =: queryString OR MobilePhone =: queryString];
	}
	
	@AuraEnabled
	public static List<Account> handleAccount(Id contactId, String activityId) {
		List<Account> accounts = getAccounts(contactId);

		if(accounts.size() == 1) {
			updateActivity(activityId, null, accounts[0].Id);
		}

		return accounts;
	}

	@AuraEnabled
	public static List<Account> getAccounts(String contactId) {
		Contact contact = [SELECT Id, Account.Id FROM Contact WHERE Id =: contactId];
		List<Account> accounts = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId)];
		accounts.add(0, contact.Account);

		return accounts;
	}

	@AuraEnabled
	public static Integer updateActivity(String activityId, String contactId, String accountId) {
		wrts_prcgvr__Activity__c a = new wrts_prcgvr__Activity__c(
			Id = activityId
		);

		if(contactId != null) {
			a.Contact__c = contactId;
		}
		if(accountId != null) {
			a.Account__c = accountId;
		}

		try {
			update a;
		} catch (Exception e) {
			// WIP
		}

		return 0;
	}
}