public with sharing class HDT_LC_AccountSelectorController {
	private class HDT_UTL_Struct {
		String accountId;
		String contactId;
		List<Account> accounts;
		List<Contact> contacts;
	}
	
	@AuraEnabled
	public static String init(String recordId) {
		if(!Schema.sObjectType.wrts_prcgvr__Activity__c.isAccessible()) {
			return null;
		}

		try {
			wrts_prcgvr__Activity__c activity = [SELECT Id, Account__c, Contact__c, ClientNumber__c FROM wrts_prcgvr__Activity__c WHERE Id =: recordId];
			
			HDT_UTL_Struct result = new HDT_UTL_Struct();
			result.accountId = activity.Account__c;
			result.contactId = activity.Contact__c;

			if(String.isBlank(activity.Contact__c) && String.isNotBlank(activity.ClientNumber__c)) {
				result.contacts = getContacts(activity.ClientNumber__c);
			} else if(String.isBlank(activity.Account__c)) {
				result.accounts = handleAccount(activity.Contact__c, activity.Id);
			}

			return JSON.serialize(result);
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Contact> getContacts(String queryString) {
		if(!Schema.sObjectType.Contact.isAccessible()) {
			return null;
		}

		try {
			return [SELECT Id, AccountId, Name, Phone, MobilePhone, Email FROM Contact WHERE Name =: queryString OR Phone =: queryString OR MobilePhone =: queryString OR Email LIKE: queryString];
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}
	
	@AuraEnabled
	public static List<Account> handleAccount(Id contactId, String activityId) {
		try {
			List<Account> accounts = getAccounts(contactId);

			if(accounts.size() == 1) {
				updateActivity(activityId, contactId, accounts[0].Id);
			}

			return accounts;
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Account> getAccounts(String contactId) {
		if(!Schema.sObjectType.Account.isAccessible()) {
			return null;
		}

		try {
			return [SELECT Id, Name, FiscalCode__c, VATNumber__c, BillingAddressFormula__c  FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId)];
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static void updateActivity(String activityId, String contactId, String accountId) {
		if(!Schema.sObjectType.wrts_prcgvr__Activity__c.isUpdateable()) {
			return;
		}

		try {
			wrts_prcgvr__Activity__c a = new wrts_prcgvr__Activity__c(
				Id = activityId
			);

			if(contactId != null) {
				a.Contact__c = contactId;
			}
			if(accountId != null) {
				a.Account__c = accountId;
			}

			update a;
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static String reset(String activityId) {
		if(!Schema.sObjectType.wrts_prcgvr__Activity__c.isUpdateable()) {
			return null;
		}

		try {
			update new wrts_prcgvr__Activity__c(
				Id = activityId,
				Contact__c = null,
				Account__c = null
			);
			return null;
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}
}