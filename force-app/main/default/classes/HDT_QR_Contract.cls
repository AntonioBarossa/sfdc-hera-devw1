
public with sharing class HDT_QR_Contract {

    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();

    public HDT_QR_Contract() {

    }
        /**

    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get active records by accountId
    * @param String accountId
    * @return List<Contract>
    */
    public List<Contract> getActiveRecordsByAccountId(String accountId){
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

    @AuraEnabled(cacheable=true)
    public static Contract getContractFromRow(string cNumber,string accountId){
    system.debug('getContractFromRow START '+ cNumber);
    contractSrv.checkReadAccess('Name,AccountId,ContractNumber,Status');
    contractQr.getActiveRecordsByAccountId(accountId);
    Contract c = new Contract() ;
    List<Contract> con = [SELECT  Id, AccountId, Pricebook2Id, OwnerExpirationNotice, StartDate, EndDate, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
    ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, ContractTerm, OwnerId, Status, CompanySignedId, CompanySignedDate, CustomerSignedId,
    CustomerSignedTitle, CustomerSignedDate, SpecialTerms, ActivatedById, ActivatedDate, StatusCode, Description, IsDeleted, ContractNumber, LastApprovedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, SBQQ__ActiveContract__c, SBQQ__AmendmentOpportunityRecordTypeId__c,
    SBQQ__AmendmentOpportunityStage__c, SBQQ__AmendmentOwner__c, SBQQ__AmendmentPricebookId__c, SBQQ__AmendmentRenewalBehavior__c, SBQQ__AmendmentStartDate__c, SBQQ__DefaultRenewalContactRoles__c, SBQQ__DefaultRenewalPartners__c, SBQQ__DisableAmendmentCoTerm__c, SBQQ__Evergreen__c, SBQQ__ExpirationDate__c, SBQQ__MDQRenewalBehavior__c, SBQQ__MasterContract__c,
    SBQQ__OpportunityPricebookId__c, SBQQ__Opportunity__c, SBQQ__Order__c, SBQQ__PreserveBundleStructureUponRenewals__c, SBQQ__Quote__c, SBQQ__RenewalForecast__c, SBQQ__RenewalOpportunityRecordTypeId__c, SBQQ__RenewalOpportunityStage__c, SBQQ__RenewalOpportunity__c, SBQQ__RenewalOwner__c, SBQQ__RenewalPricebookId__c, SBQQ__RenewalQuoted__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__SubscriptionQuantitiesCombined__c, SAPContractCode__c
    FROM Contract WHERE ContractNumber = :cNumber];
    if(con != null && con.size()> 0){
        c= con[0];
    }
    
    

    system.debug('getContractFromRow END ' + con);
    return c;
 }

}
