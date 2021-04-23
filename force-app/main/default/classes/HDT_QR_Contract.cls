
public inherited sharing class HDT_QR_Contract {

    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static string fields = 'Id, AccountId, Pricebook2Id, OwnerExpirationNotice, StartDate, EndDate, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, ContractTerm, OwnerId, Status, CompanySignedId, CompanySignedDate, CustomerSignedId, CustomerSignedTitle, CustomerSignedDate, SpecialTerms, ActivatedById, ActivatedDate, StatusCode, Description, IsDeleted, ContractNumber, LastApprovedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, SBQQ__ActiveContract__c, SBQQ__AmendmentOpportunityRecordTypeId__c, SBQQ__AmendmentOpportunityStage__c, SBQQ__AmendmentOwner__c, SBQQ__AmendmentPricebookId__c, SBQQ__AmendmentRenewalBehavior__c, SBQQ__AmendmentStartDate__c, SBQQ__DefaultRenewalContactRoles__c, SBQQ__DefaultRenewalPartners__c, SBQQ__DisableAmendmentCoTerm__c, SBQQ__Evergreen__c, SBQQ__ExpirationDate__c, SBQQ__MDQRenewalBehavior__c, SBQQ__MasterContract__c, SBQQ__OpportunityPricebookId__c, SBQQ__Opportunity__c, SBQQ__Order__c, SBQQ__PreserveBundleStructureUponRenewals__c, SBQQ__Quote__c, SBQQ__RenewalForecast__c, SBQQ__RenewalOpportunityRecordTypeId__c, SBQQ__RenewalOpportunityStage__c, SBQQ__RenewalOpportunity__c, SBQQ__RenewalOwner__c, SBQQ__RenewalPricebookId__c, SBQQ__RenewalQuoted__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__SubscriptionQuantitiesCombined__c, SAPContractCode__c';


    public HDT_QR_Contract() {

    }


    public List<BillingProfile__c> getInd(String accountId) {
        contractSrv.checkReadAccess('Status__c,Account__c,InvoicingAddressFormula__c');
        System.debug('accountId ***********' + accountId);
        System.debug('LISTA BILLINGPROFILE ***********' +[SELECT Status__c,Account__c,InvoicingAddressFormula__c FROM BillingProfile__c WHERE Account__c =: accountId  WITH SECURITY_ENFORCED] );
		return [SELECT Status__c,Account__c,InvoicingAddressFormula__c FROM BillingProfile__c WHERE Account__c =: accountId WITH SECURITY_ENFORCED];							  
		  
	}

    public List<Contract> getRecordById(String contractId){
        return [
            SELECT
            Name,
            AccountId,
            ContractNumber,
            BillingProfile__c,
            Status,
            SBQQ__Order__r.BillingProfile__c
            FROM
            Contract
            WHERE Id = :contractId
            WITH SECURITY_ENFORCED
        ];
}	
        /**	   
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get active records by accountId
    * @param String accountId
    * @return List<Contract>
    */
    public List<Contract> getActiveRecordsByAccountId(String accountId){
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,Status'); 
        return [
            SELECT
            Name,
            AccountId,			
            ContractNumber,
            Status 
            FROM
            Contract
            WHERE AccountId = :accountId									 
            AND Status = 'Activated'
            WITH SECURITY_ENFORCED
        ];
    }

	    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get active records by accountId and servicePointId
    * @param String accountId
    * @param String servicePointId
    * @return List<Contract>
    */
    public List<Contract> getActiveRecordsByAccountIdAndServicePointId(String accountId, String servicePointId){
        return [
            SELECT
            Name,
            AccountId,
            ServicePoint__c,
            ContractNumber,
            Status 
            FROM
            Contract
            WHERE AccountId = :accountId
            AND ServicePoint__c = :servicePointId
            AND Status = 'Activated'
            WITH SECURITY_ENFORCED
        ];
    }
   
    @AuraEnabled(cacheable=true)
    public static Contract getContractFromRow(string cNumber,string accountId){
    system.debug('getContractFromRow START '+ cNumber);
    contractSrv.checkReadAccess(fields); 
    Contract c = new Contract() ;
    List<Contract> con = Database.query('SELECT '+fields +' FROM Contract WHERE ContractNumber =: cNumber WITH SECURITY_ENFORCED');

    if(con != null && con.size()> 0){
        c= con[0];
    }
    system.debug('getContractFromRow END ' );
    return c ;
 }

  	/*
	 * Query for Getting All Account Contracts
	 */
	public List<Contract> getAccountContractsWithFilter(String accountid,String additionalFilter) {
        system.debug('getAccountContractsWithFilter START');
        contractSrv.checkReadAccess('ContractNumber, Status, Account.Name, AccountId,SAPContractCode__c');
        String query = 'SELECT ContractNumber, Status, Account.Name, AccountId,SAPContractCode__c FROM Contract WHERE AccountId =: accountid '+additionalFilter+' WITH SECURITY_ENFORCED';
		List<Contract> listCon = Database.query(query);
        system.debug('getAccountContractsWithFilter END' + listCon);
		return listCon;
	}


 	/*
	 * Query for Getting All Account Contracts
	 */
	public List<Contract> getAccountContracts(String accountid) {
        contractSrv.checkReadAccess('ContractNumber, Status, Account.Name, AccountId,SAPContractCode__c');
		return [SELECT ContractNumber, Status, Account.Name, AccountId,SAPContractCode__c FROM Contract WHERE AccountId =: accountid  WITH SECURITY_ENFORCED];
	}

    public List<Contract> getAccountContractsWithFilter(String fields, String accountid,String additionalFilter) {
        system.debug('getAccountContractsWithFilter START :' + fields);
        contractSrv.checkReadAccess(fields);
        String query = 'SELECT ' + fields + ' FROM Contract WHERE AccountId =: accountid '+additionalFilter+' WITH SECURITY_ENFORCED';
		List<Contract> listCon = Database.query(query);
        system.debug('getAccountContractsWithFilter END' + listCon);
		return listCon;
	}


 	/*
	 * Query for Getting All Account Contracts
	 */
	public List<Contract> getAccountContracts(String fields , String accountid) {
        contractSrv.checkReadAccess(fields);
		String query = 'SELECT ' + fields + ' FROM Contract WHERE AccountId =: accountid WITH SECURITY_ENFORCED';
		List<Contract> listCon = Database.query(query);
        return listCon;
    }

}
