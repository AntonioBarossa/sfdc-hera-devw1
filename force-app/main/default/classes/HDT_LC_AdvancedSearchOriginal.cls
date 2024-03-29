public with sharing class HDT_LC_AdvancedSearchOriginal {
//	private static Set<String> supplyFieldSet = new Set<String>{
//		'Id', 'Name', 'RecordTypeId', 'RecordType.Name', 'Status__c', 'CompanyDivision__c', 'CompanyDivision__r.Name', 'Product__c', 'Product__r.Name', 
//		'ServicePoint__c', 'ServicePoint__r.Name', 
//		'Account__c', 'Account__r.Name', 
//		'Contract__c', 'Contract__r.ContractNumber', 'Contract__r.Account.Name', 'Contract__r.AccountId', 
//		'ContractAccount__c', 'ContractAccount__r.Name', 'ContractAccount__r.Key__c', 'ContractAccount__r.Account__r.Name', 
//		'ServiceSite__c', 'ServiceSite__r.Name', 'ServiceSite__r.Account__c', 'ServiceSite__r.SiteAddress__c', 
//		'ServiceSite__r.Account__r.Name', 'ServiceSite__r.SiteAddressKey__c'
//	};
//	//TEST
//	private static Set<String> pointFieldSet = new Set<String>{
//		'Id', 'Name', 'Key__c', 'RecordTypeId', 'RecordType.Name', 'CurrentSupply__r.CompanyDivision__r.Name', 
//		'CurrentSupply__c', 'CurrentSupply__r.Name', 'CurrentSupply__r.Key__c', 'CurrentSupply__r.Status__c', 
//		'CurrentSupply__r.CompanyDivision__c', 'CurrentSupply__r.Product__c', 'CurrentSupply__r.Product__r.Name', 
//		'CurrentSupply__r.Account__c', 'CurrentSupply__r.Account__r.Name', 'CurrentSupply__r.Account__r.Key__c', 'CurrentSupply__r.ContractAccount__r.Account__r.Name', 
//		'CurrentSupply__r.ContractAccount__c', 'CurrentSupply__r.ContractAccount__r.Name', 'CurrentSupply__r.ContractAccount__r.Key__c', 
//		'CurrentSupply__r.ServiceSite__c', 'CurrentSupply__r.ServiceSite__r.Name', 'CurrentSupply__r.ServiceSite__r.SiteAddressKey__c', 
//		'CurrentSupply__r.ServiceSite__r.Account__c', 'CurrentSupply__r.ServiceSite__r.Account__r.Name', 'CurrentSupply__r.ServiceSite__r.SiteAddress__c', 
//		'CurrentSupply__r.Contract__c', 'CurrentSupply__r.Contract__r.ContractNumber', 'CurrentSupply__r.Contract__r.AccountId', 'CurrentSupply__r.Contract__r.Account.Name'
//	};
//
//	@AuraEnabled
//	public static List<ServicePoint__c> queryServicePoint(String searchText, String accountId, List<String> supplyStatus, String companyDivision, List<String> fields) {
//		if(String.isBlank(searchText) && String.isBlank(accountId) && String.isBlank(companyDivision) && (supplyStatus == null || supplyStatus.isEmpty())) {
//		//	throw new WrtsException(System.Label.AtLeastOneQueryFilterMustBeSet);
//		}
//
//		Set<String> fieldSet = pointFieldSet;
//		fieldSet.addAll(fields);
//		String query = 'SELECT ' + String.join(new List<String>(fieldSet), ', ') + ' FROM ServicePoint__c ';
//
//		List<String> queryConditions = new List<String>();
//		if(String.isNotBlank(accountId)) {
//			queryConditions.add('CurrentSupply__r.Account__c = :accountId');
//		}
//
//		if(supplyStatus != null && !supplyStatus.isEmpty()) {
//			queryConditions.add('CurrentSupply__r.Status__c IN :supplyStatus');
//		}
//
//		if(String.isNotBlank(companyDivision)) {
//			queryConditions.add('CurrentSupply__r.CompanyDivision__c = :companyDivision');
//		}
//
//		List<String> searchFilters = new List<String>();
//		if(String.isNotBlank(searchText)) {
//			if(String.isBlank(accountId)) {
//				searchFilters.add('CurrentSupply__r.Account__r.Name LIKE :text');
//				//String reverseText = '%' + reverseWords(searchText).replaceAll(' ', '%') + '%';
//				searchFilters.add('CurrentSupply__r.Account__r.Name LIKE :reverseText');
//				searchFilters.add('CurrentSupply__r.Account__r.Key__c LIKE :text');
//			}
//			searchFilters.add('CurrentSupply__r.ContractAccount__r.Name LIKE :text');
//			searchFilters.add('CurrentSupply__r.ContractAccount__r.Key__c LIKE :text');
//			searchFilters.add('CurrentSupply__r.Key__c LIKE :text');
//			searchFilters.add('Key__c LIKE :text');
//			searchFilters.add('Name LIKE :text');
//		}
//
//		if(!searchFilters.isEmpty() || !queryConditions.isEmpty()) {
//			List<String> whereClause = new List<String>();
//			if(!queryConditions.isEmpty()) {
//				whereClause.add(String.join(queryConditions, ' AND '));
//			}
//			if(!searchFilters.isEmpty()) {
//				whereClause.add('(' + String.join(searchFilters, ' OR ') + ')');
//			}
//			query += ' WHERE ' + String.join(whereClause, ' AND ');
//		}
//		query += ' LIMIT 50000';
//		List<ServicePoint__c> result;
//		if(Schema.SObjectType.ServicePoint__c.isAccessible()) {
//			result= Database.query(String.escapeSingleQuotes(query));
//		}
//		return result;
//	}
//
//
//	@AuraEnabled
//	public static List<ServicePoint__c> searchServicePoint(String searchText, String accountId, List<String> supplyStatus, String companyDivision, List<String> fields) {
//		if(String.isBlank(searchText) && String.isBlank(accountId) && String.isBlank(companyDivision)) {
//			//throw new WrtsException(System.Label.AtLeastOneQueryFilterMustBeSet);
//		}
//
//		List<ServicePoint__c> result = new List<ServicePoint__c>();
//		List<List<SObject>> searchList = [FIND :searchText IN ALL FIELDS
//									      RETURNING Account(Id), Contract(Id)/*, ServiceSite__c(Id), BillingProfile__c(Id), ContractAccount__c(Id), Supply__c(Id), ServicePoint__c(Id)*/];
//		Set<Id> searchAccounts = new Map<Id, Account>((Account []) searchList [0]).keySet();
//		Set<Id> searchContacts = new Map<Id, Contract>((Contract []) searchList [1]).keySet();
//		Set<Id> searchServicePoints = new Map<Id, ServicePoint__c>((ServicePoint__c []) searchList [6]).keySet();
//
//		Set<String> fieldSet = pointFieldSet;
//		fieldSet.addAll(fields);
//
//		String query = 'SELECT ' + String.join(new List<String>(fieldSet), ', ') + ' FROM ServicePoint__c ';
//
//		List<String> andConditions = new List<String>();
//		List<String> orConditions = new List<String>();
//		if(String.isNotBlank(accountId)) {
//			ANDConditions.add('CurrentSupply__r.Account__c = :accountId');
//		}
//
//		if(supplyStatus != null && !supplyStatus.isEmpty()) {
//			ANDConditions.add('CurrentSupply__r.Status__c IN :supplyStatus');
//		}
//
//		if(String.isNotBlank(companyDivision)) {
//			ANDConditions.add('CurrentSupply__r.CompanyDivision__c = :companyDivision');
//		}
//
//		if(!searchAccounts.isEmpty()) {
//			ORConditions.add('CurrentSupply__r.Account__c in :searchAccounts');
//		}
//		if(!searchContacts.isEmpty()) {
//			ORConditions.add('CurrentSupply__r.Contract__c in :searchContacts');
//		}
//
//		if(!searchServicePoints.isEmpty()) {
//			ORConditions.add('Id in :searchServicePoints');
//		}
//
//		if(ORConditions.isEmpty()) {
//			return result;
//		}
//
//		if(!ORConditions.isEmpty() || !ANDConditions.isEmpty()) {
//			List<String> whereClause = new List<String>();
//			if(!ANDConditions.isEmpty()) {
//				whereClause.add(String.join(ANDConditions, ' AND '));
//			}
//			if(!ORConditions.isEmpty()) {
//				whereClause.add('(' + String.join(ORConditions, ' OR ') + ')');
//			}
//			query += ' WHERE ' + String.join(whereClause, ' AND ');
//		}
//
//		query += ' LIMIT 50000';
//		if(Schema.SObjectType.ServicePoint__c.isAccessible()) {
//			result = Database.query(String.escapeSingleQuotes(query));
//		}
//		return result;
//	}
//
//	private static String reverseWords(String text) {
//		List<String> reverseString = new List<String>();
//
//		String[] words = text.split(' ');
//
//		for(Integer i = words.size() -1; i >= 0; i --) {
//			reverseString.add(words [i]);
//		}
//		return String.join(reverseString, ' ');
//	}
//
}
