/**
 * @author Luca Molino (luca.molino@engdb.com.br)
 * @date 29/01/2021
 * @description HDT_QR_Contract Class
 * @history Luca Molino – 29/01/2021 – Created Class
 */

public inherited sharing class HDT_QR_Contract {

    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static string fields = 'Id, AccountId, Pricebook2Id, OwnerExpirationNotice, StartDate, EndDate, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, ContractTerm, OwnerId, Status, CompanySignedId, CompanySignedDate, CustomerSignedId, CustomerSignedTitle, CustomerSignedDate, SpecialTerms, ActivatedById, ActivatedDate, StatusCode, Description, IsDeleted, ContractNumber, LastApprovedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, SBQQ__ActiveContract__c, SBQQ__AmendmentOpportunityRecordTypeId__c, SBQQ__AmendmentOpportunityStage__c, SBQQ__AmendmentOwner__c, SBQQ__AmendmentPricebookId__c, SBQQ__AmendmentRenewalBehavior__c, SBQQ__AmendmentStartDate__c, SBQQ__DefaultRenewalContactRoles__c, SBQQ__DefaultRenewalPartners__c, SBQQ__DisableAmendmentCoTerm__c, SBQQ__Evergreen__c, SBQQ__ExpirationDate__c, SBQQ__MDQRenewalBehavior__c, SBQQ__MasterContract__c, SBQQ__OpportunityPricebookId__c, SBQQ__Opportunity__c, SBQQ__Order__c, SBQQ__PreserveBundleStructureUponRenewals__c, SBQQ__Quote__c, SBQQ__RenewalForecast__c, SBQQ__RenewalOpportunityRecordTypeId__c, SBQQ__RenewalOpportunityStage__c, SBQQ__RenewalOpportunity__c, SBQQ__RenewalOwner__c, SBQQ__RenewalPricebookId__c, SBQQ__RenewalQuoted__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__SubscriptionQuantitiesCombined__c, SAPContractCode__c';

    public List<Contract> getRecordsWithContractsByServicePointAndAccountId(String servicePointId, String accountId){

        return [
            SELECT 
            Id, Status,AccountId,ServicePoint__c 
            FROM Contract 
            WHERE AccountId =: accountId AND ServicePoint__c=: servicePointId AND Status='Attivo'
            WITH SECURITY_ENFORCED
        ];
    }

    public List<BillingProfile__c> getInd(String accountId) {
        contractSrv.checkReadAccess('Status__c,Account__c,InvoicingAddressFormula__c');
        System.debug('accountId ***********' + accountId);
        System.debug('LISTA BILLINGPROFILE ***********' +[SELECT Status__c,Account__c,InvoicingAddressFormula__c FROM BillingProfile__c WHERE Account__c =: accountId  WITH SECURITY_ENFORCED] );
		return [SELECT Status__c,Account__c,InvoicingAddressFormula__c FROM BillingProfile__c WHERE Account__c =: accountId WITH SECURITY_ENFORCED];							  
		  
	}

    public Contract getSapContractCode(String code,Boolean isSuperUser) {
        contractSrv.checkReadAccess('Id, ServicePoint__r.ServicePointCode__c, ServicePoint__c, SAPContractCode__c,Status');
        String filter = 'Attivo';
        List<Contract> con= new List<Contract>();
        Contract c = new Contract();
        if(code==null){
            code = '';
        }
        if(isSuperUser==true){
           con = Database.query('SELECT Id, ServicePoint__r.ServicePointCode__c, ServicePoint__c, SAPContractCode__c,Status,CreatedDate FROM Contract  WHERE ServicePoint__c = ' + '\'' + String.escapeSingleQuotes(code) + '\'' +' LIMIT 1');
        }else{
           con = Database.query('SELECT Id, ServicePoint__r.ServicePointCode__c, ServicePoint__c, SAPContractCode__c,Status FROM Contract  WHERE ServicePoint__c = ' + '\'' + String.escapeSingleQuotes(code) + '\'' + ' AND Status=' + '\'' + String.escapeSingleQuotes(filter) + '\'' + 'WITH SECURITY_ENFORCED');
        }

        if(con != null && con.size()> 0){
            c= con[0];
        }
        system.debug('contract ******************** : ' + c);
        return c;
	}

    public List<Contract> getSapContractCode(List<String> codes) {
        contractSrv.checkReadAccess('Id, ServicePoint__c, ServicePoint__r.ServicePointCode__c, SAPContractCode__c,Status');
        String filter = 'Attivo';       
        List<Contract> contractList = Database.query('SELECT Id, ServicePoint__c, ServicePoint__r.ServicePointCode__c, SAPContractCode__c,Status FROM Contract  WHERE ServicePoint__c IN:codes AND Status= \''+String.escapeSingleQuotes(filter)+'\''+ ' WITH SECURITY_ENFORCED');

        return contractList;
	}

    public List<Contract> getRecordById(String contractId){
        return [
            SELECT
            Name,
            AccountId,
            ContractNumber,
            SAPContractCode__c,
            Status,
            BillingProfile__c,
            SBQQ__Order__r.BillingProfile__c,
            ServicePoint__c,
            ServicePoint__r.RecordType.DeveloperName
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
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,Status,SAPContractCode__c'); 
        return [
            SELECT
            Id,
            Name,
            AccountId,			
            ContractNumber,
            Status,
            ServicePoint__c,
            BillingProfile__c,
            SAPContractCode__c,
            ServicePoint__r.ServicePointCode__c,
            ServicePoint__r.SupplyAddress__c,
            ServicePoint__r.SupplyCity__c,
            ServicePoint__r.Vendor__c
            FROM
            Contract
            WHERE AccountId = :accountId									 
            AND Status IN ('Activated', 'Attivo')
            AND CommoditySectorFormula__c IN ('Energia Elettrica', 'Gas')
            WITH SECURITY_ENFORCED
        ];
    }

    /**	   
    * @author Federico de Felice (federico.defelice@webresults.it)
    * @description Get active records by accountId
    * @param String accountId
    * @return List<Contract>
    */
    public List<Contract> getTempNewActivationContractsByAccountId(String accountId){
        Date maxDate = Date.newInstance(2099, 1, 1);
        contractSrv.checkReadAccess('Name,AccountId,ContractNumber,Status,SAPContractCode__c'); 
        return [
            SELECT
            Name,
            AccountId,			
            ContractNumber,
            Status,
            ServicePoint__c,
            SAPContractCode__c,
            ServicePoint__r.ServicePointCode__c,
            ServicePoint__r.SupplyAddress__c
            FROM
            Contract
            WHERE AccountId = :accountId									 
            AND Status IN ('Activated', 'Attivo')
            AND EndDate < :maxDate
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
            BillingProfile__c,
            ServicePoint__c,
            ContractNumber,
            Status 
            FROM
            Contract
            WHERE AccountId = :accountId
            AND ServicePoint__c = :servicePointId
            AND Status IN ('Activated', 'Attivo')
            WITH SECURITY_ENFORCED
        ];
    }
   
    @AuraEnabled(cacheable=true)
    public static Contract getContractFromRow(string cNumber,string accountId){
    system.debug('getContractFromRow START ');
    contractSrv.checkReadAccess(fields); 
    Contract c = new Contract() ;
    List<Contract> con = Database.query('SELECT '+ String.escapeSingleQuotes(fields) +' FROM Contract WHERE ContractNumber =: cNumber WITH SECURITY_ENFORCED');

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
        
        // changed because throws error: no viable alternative at character '\'
        // String query = 'SELECT ContractNumber, Status, Account.Name, AccountId,SAPContractCode__c FROM Contract WHERE AccountId = ' + '\'' + String.escapeSingleQuotes(accountid) + '\'' + ' ' + String.escapeSingleQuotes(additionalFilter) + ' WITH SECURITY_ENFORCED';
		List<Contract> listCon = Database.query('SELECT ContractNumber, Status, Account.Name, AccountId,SAPContractCode__c FROM Contract WHERE AccountId = ' + '\'' + String.escapeSingleQuotes(accountid) + '\'' + ' ' + String.escapeSingleQuotes(additionalFilter) + ' WITH SECURITY_ENFORCED');
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
        system.debug('getAccountContractsWithFilter START');
        contractSrv.checkReadAccess(fields);
        // changed because throws error: no viable alternative at character '\'
        // String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Contract WHERE AccountId =: accountid '+ String.escapeSingleQuotes(additionalFilter) +' WITH SECURITY_ENFORCED';
		List<Contract> listCon = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Contract WHERE AccountId =: accountid '+ String.escapeSingleQuotes(additionalFilter) +' WITH SECURITY_ENFORCED');
        system.debug('getAccountContractsWithFilter END' + listCon);
		return listCon;
	}


 	/*
	 * Query for Getting All Account Contracts
	 */
	public List<Contract> getAccountContracts(String fields , String accountid) {
        contractSrv.checkReadAccess(fields);
        // changed because throws error: no viable alternative at character '\'
		// String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Contract WHERE AccountId =: accountid WITH SECURITY_ENFORCED';
		List<Contract> listCon = Database.query('SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Contract WHERE AccountId =: accountid WITH SECURITY_ENFORCED');
        return listCon;
    }



    public List<Contract> getRecordsWithOrders(List<String> contractIds){
        return [
            SELECT
            SBQQ__Order__c,
            SBQQ__Order__r.BillingProfile__c,
            SBQQ__Order__r.ServicePoint__c
            FROM
            Contract
            WHERE Id IN :contractIds
            WITH SECURITY_ENFORCED
        ];
    }
    public List<Contract> getContractFromServicePoint(String servicePointId){

        return [SELECT Id,
        SAPContractCode__c,
        AccountId
        FROM Contract
        WHERE ServicePoint__c = :servicePointId
        AND Status = 'Attivo'
        WITH SECURITY_ENFORCED];

    }

    public Contract getContractAccountCompanyOwner(String contractId) {
        return [SELECT Account.CompanyOwner__c
        FROM Contract
        WHERE Id = :contractId
        WITH SECURITY_ENFORCED
        LIMIT 1];
    }

    public SBQQ__Subscription__c  getSubscriptionFromContract(String contractId){
        return [SELECT Id,
        SBQQ__Product__c,
        ProductCode__c,
        SBQQ__ProductName__c,
        CategoryFamily__c,
        VersionFormula__c, 
        SBQQ__Product__r.Family 
        FROM SBQQ__Subscription__c 
        WHERE SBQQ__Contract__c =:contractId 
        AND SBQQ__Product__r.Family = 'Offerta commerciale'
        WITH SECURITY_ENFORCED
        LIMIT 1];
    }

    public List<SBQQ__Subscription__c>  getSubscriptionsFromContract(String contractId){
        return [SELECT Id,
                SBQQ__Product__c,
                ProductCode__c,
                SBQQ__ProductName__c,
                CategoryFamily__c,
                VersionFormula__c,
                SBQQ__Product__r.Family,
                SBQQ__Product__r.ProductCode
        FROM SBQQ__Subscription__c
        WHERE SBQQ__Contract__c =:contractId
        WITH SECURITY_ENFORCED];
    }

    public static Contract getContractWithSubscriptions(Id servicePointId){
        if(String.isBlank(servicePointId))return null;
        return [SELECT Id,EndDate, StartDate,(select Id,SBQQ__RequiredById__c from SBQQ__Subscriptions__r) FROM Contract WHERE ServicePoint__c =:servicePointId AND Status='Attivo' LIMIT 1];
    }

    public List<Contract> getContractByContractCodeConsumoAnomaloIdrico(Set<String> sapCodes){
        return [SELECT Id,SAPContractCode__c,ContractSalesCompany__c,Market__c,ServicePoint__c,ServicePoint__r.ServicePointCode__c,ServicePoint__r.JointBottomAdhesion__c,
                ServicePoint__r.PaySewer__c, ServicePoint__r.PayPurification__c, ServicePoint__r.MeterSN__c, ServicePoint__r.CommoditySector__c,
                ServicePoint__r.Distributor__c, ServicePoint__r.SupplyType__c, Contact__c,AccountId,Account.PrimaryEmail__c,
                Account.SAPIntegrationID__c,Account.CustomerCode__c ,BillingProfile__r.InvoicingAddressFormula__c,BillingProfile__r.InvoicingCity__c, BillingProfile__r.InvoicingCountry__c,
                BillingProfile__r.InvoicingPlace__c, BillingProfile__r.InvoicingPostalCode__c, BillingProfile__r.InvoicingProvince__c, BillingProfile__r.InvoicingStreetName__c, BillingProfile__r.InvoicingStreetNumber__c,
                BillingProfile__r.InvoicingStreetNumberExtension__c,BillingProfile__r.InvoiceEmailAddress__c,BillingProfile__r.InvoiceCertifiedEmailAddress__c,BillingProfile__r.ElectronicInvoiceCertifiedEmailAddress__c ,ServicePoint__r.AnnualConsumption__c, ServicePoint__r.MeterClass__c,
                ServicePoint__r.Disconnectable__c, ServicePoint__r.Distributor__r.Code__c, ServicePoint__r.MarketOrigin__c, ServicePoint__r.PurificationInfoOnTheInvoice__c, ServicePoint__r.RateCategory__c,
                ServicePoint__r.ResidentDomesticHousingUnit__c, ServicePoint__r.NotDomesticHousingUnit__c, ServicePoint__r.ImplantTypeTemp__c,
                ServicePoint__r.SupplyCity__c, ServicePoint__r.SupplySAPCityCode__c, ServicePoint__r.SupplyCountry__c, ServicePoint__r.SupplyPostalCode__c, ServicePoint__r.SupplyProvince__c,
                ServicePoint__r.SupplySAPStreetCode__c, ServicePoint__r.SupplyStreet__c, ServicePoint__r.SupplyStreetNumber__c, ServicePoint__r.SAPImplantCode__c
                FROM Contract
                WHERE SAPContractCode__c IN: sapCodes WITH SECURITY_ENFORCED];
    }

    public List<Contract> getContractBySapCodeBpManagementBulk(Set<String> sapCodes){
        return [SELECT Id,BillingProfile__c,AccountId,Account.Category__c,ServicePoint__c, ServicePoint__r.ServicePointCode__c, SAPContractCode__c, Account.BillingState, Account.BillingStreetNumber__c, Account.BillingPlace__c, Account.BillingStreetName__c, Account.BillingPostalCode, Account.BillingCountry, Account.BillingCityCode__c, Account.FirstName__c, Account.LastName__c, Account.VATNumber__c, Account.FiscalCode__c FROM Contract WHERE SAPContractCode__c IN: sapCodes WITH SECURITY_ENFORCED ];
    }

    public List<Contract> getContractBySapCodeWithStatusActive(Set<String> sapCodes){
        String filterStatus = 'Attivo';
        return [SELECT Id,SAPContractCode__c FROM Contract WHERE SAPContractCode__c IN: sapCodes AND Status =: filterStatus WITH SECURITY_ENFORCED ];
    }

}