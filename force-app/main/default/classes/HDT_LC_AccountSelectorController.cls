public with sharing class HDT_LC_AccountSelectorController {
	private class HDT_UTL_Struct {
		Boolean isCall;
		String preFilter;
		String accountId;
		String contactId;
		String leadId;
		List<Account> accounts;
		List<Contact> contacts;
		List<Lead> leads;
	}
	
	@AuraEnabled
	public static String init(String recordId) {
		try {
			wrts_prcgvr__Activity__c activity = [SELECT Id, Account__c, Contact__c, Lead__c, BPCode__c, ClientNumber__c, FiscalCode__c, VATNumber__c, Type__c, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
			
			HDT_UTL_Struct result = new HDT_UTL_Struct();
			result.isCall = activity.Type__c.contains('Chiamata');
			result.accountId = activity.Account__c;
			result.contactId = activity.Contact__c;
			result.leadId = activity.Lead__c;

			if(activity.wrts_prcgvr__Status__c != 'Completed') {
				if(String.isNotBlank(activity.BPCode__c)) {
					result.preFilter = activity.BPCode__c;
				} else if(String.isNotBlank(activity.FiscalCode__c)) {
					result.preFilter = activity.FiscalCode__c;
				} else if(String.isNotBlank(activity.VATNumber__c)) {
					result.preFilter = activity.VATNumber__c;
				} else if(String.isNotBlank(activity.ClientNumber__c)) {
					result.preFilter = activity.ClientNumber__c;
				}

				if(String.isBlank(activity.Contact__c) && String.isBlank(activity.Lead__c) && String.isNotBlank(result.preFilter)) {
					result.contacts = getContacts(result.preFilter);
					result.leads = getLeads(result.preFilter);
					if(result.contacts.size() == 1 && result.leads.isEmpty()) {
						String contactId = result.contacts.get(0).Id;
						result.contactId = contactId;
						result.accounts = handleAccount(contactId, activity.Id);
						if(result.accounts.size() == 1) result.accountId = result.accounts.get(0).Id;
					} else if(result.contacts.isEmpty() && result.leads.size() == 1) {
						String leadId = result.leads.get(0).Id;
						handleLead(leadId, activity.Id);
						result.leadId = leadId;
					}
				} else if(String.isBlank(activity.Account__c)) {
					result.accounts = handleAccount(activity.Contact__c, activity.Id);
				}
			}

			return JSON.serialize(result);
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static String search(String queryString) {
		try {
			HDT_UTL_Struct result = new HDT_UTL_Struct();
			if(queryString.startsWith('100') && queryString.isNumeric()) {
				// return handleBPCodeSearch(queryString);
				result.accounts = getAccountByBPCode(queryString);
				result.contacts = getContactTitolare(result.accounts.get(0).Id);
			} else {
				queryString = '%' + queryString + '%';
				result.leads = getLeads(queryString);
				result.contacts = getContacts(queryString);
			}
			return JSON.serialize(result);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static List<Account> getAccountByBPCode(String bpCode) {
		return [SELECT Id, Name, FiscalCode__c, VATNumber__c, BillingAddressFormula__c FROM Account WHERE CustomerCode__c = :bpCode];
	}

	private static List<Contact> getContactTitolare(String accountId) {
		return [SELECT Id, Name, Phone, MobilePhone, Email, FiscalCode__c, VATNumber__c FROM Contact WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :accountId AND Roles = 'Titolare' AND isActive = true)];
	}

	@AuraEnabled
	public static List<Contact> getContacts(String queryString) {
		try {
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
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Lead> getLeads(String queryString) {
		try {
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
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static void handleLead(String leadId, String activityId){
		try {
			updateActivity(activityId, null, null, leadId);
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Account> handleAccount(Id contactId, String activityId) {
		try {
			List<Account> accounts = getAccounts(contactId);

			if(accounts.size() == 1) {
				updateActivity(activityId, contactId, accounts[0].Id, null);
			}

			return accounts;
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Account> getAccounts(String contactId) {
		try {
			return [SELECT Id, Name, FiscalCode__c, VATNumber__c, BillingAddressFormula__c  FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId) WITH SECURITY_ENFORCED];
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static void updateActivity(String activityId, String contactId, String accountId, String leadId) {
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
			if(leadId != null) {
				a.Lead__c = leadId;
			}

			HDT_UTL_DatabaseService.updateSObject(a);
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static String reset(String activityId) {
		try {
			HDT_UTL_DatabaseService.updateSObject(new wrts_prcgvr__Activity__c(
				Id = activityId,
				Contact__c = null,
				Account__c = null,
				Lead__c = null
			));
			return null;
		} catch (Exception e) {
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
	}
}