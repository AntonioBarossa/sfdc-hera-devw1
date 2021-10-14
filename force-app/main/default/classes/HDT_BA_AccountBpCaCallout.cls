public with sharing class HDT_BA_AccountBpCaCallout implements Database.Batchable<Account>, Database.Stateful,Database.AllowsCallouts{

    public List<Account> dtos = new List<Account>();
    HDT_QR_Account accQr = new HDT_QR_Account();
    HDT_QR_Contact contactQr = new HDT_QR_Contact();
   // String selectStr = 'Id, IsDeleted, MasterRecordId, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Phone, Fax, AccountNumber, Website, PhotoUrl, Sic, Industry, AnnualRevenue, NumberOfEmployees, Ownership, TickerSymbol, Description, Rating, Site, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, IsPartner, ChannelProgramName, ChannelProgramLevelName, Jigsaw, JigsawCompanyId, AccountSource, SicDesc, SBQQ__AssetQuantitiesCombined__c, SBQQ__CoTermedContractsCombined__c, SBQQ__CoTerminationEvent__c, SBQQ__ContractCoTermination__c, SBQQ__DefaultOpportunity__c, SBQQ__IgnoreParentContractedPrices__c, SBQQ__PreserveBundle__c, SBQQ__PriceHoldEnd__c, SBQQ__RenewalModel__c, SBQQ__RenewalPricingMethod__c, SBQQ__TaxExempt__c, BillingPlace__c, BillingStreetName__c, BillingStreetNumber__c, BillingStreetNumberExtension__c, BPSAPModel__c, BillingPlaceCode__c, CompanyOwner__c, ConsentSignature__c, CustomerMarking__c, FirstName__c, LastName__c, FiscalCode__c, GlobalMigrationKey__c, IsDocumentAcquired__c, IsMigrated__c, IsWrongFiscalData__c, PrimaryEmail__c, SAPIntegrationID__c, Segment__c, CustomerAccountStatus__c, CategoryCode__c, SalesNumber__c, RegulatedMarketSelfCertification__c, VATGroupStartDate__c, VATGroupEndDate__c, IsVATGroupJoined__c, VATGroup__c, VATNumber__c, FAX__c, VirtualSAPIban__c, CustomerCode__c, RowIdSiebel__c, BillingAddessIsForeign__c, BillingRegion__c, Gender__c, BillingAddressFormula__c, BillingCityCode__c, BillingStreetCode__c, BillingStreetToponym__c, DataLimitation__c, BirthDate__c, BirthProvince__c, BuildingApartment__c, BuildingFloor__c, BuildingStairCase__c, ContactReason__c, ActiveMonitoring__c, InterestArea__c, InterestProduct__c, BillingAddressIsForeign__c, Activity__c, Age__c, ConvertedDate__c, DegreeOfStudies__c, OriginLeadId__c, Profession__c, Category__c, AccountRating__c, ActiveServicesCtrl__c, ActiveServicesEle__c, ActiveServicesGas__c, ActiveServicesTLR__c, ActiveServicesWaste__c, ActiveServicesWater__c, ActiveServices__c, ChurnkRisk__c, ComplaintRateFormula__c, ComplaintRateNum__c, CreditFormula__c, CustomerLifeCycleEle__c, CustomerLifeCycleEnergy__c, CustomerLifeCycleGas__c, CustomerLifeCycleNonEnergy__c, CustomerLifeCycleTLR__c, CustomerLifeCycleVAS__c, CustomerLifeCycleWaste__c, CustomerLifeCycleWater__c, CustomerLifeCycle__c, DataEnrichmentLastUpdate__c, PraxidiaUpdateDate__c, RecallerFormula__c, Recaller__c, SatisfactionIndexCtrl__c, SatisfactionIndex__c, LegalFormType__c, MobilePhone__c, OtherPhone__c, PhonePrefix__c, BillingIsAddressVerified__c, Code__c, Commodity__c, IsActive__c, MobilePhonePrefix__c, ShippingPlaceCode__c, ShippingPlace__c, CustomerType__c, AssistedCustomer__c, KpiTracking__c, AccountRatingCtrl__c, ChurnkRiskCtrl__c, CreditCheckCalled__c, CreditCheckCtrl__c';
    String selectStr = 'Id, IsDeleted, MasterRecordId, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Phone, Fax, AccountNumber, Website, PhotoUrl, Sic, Industry, AnnualRevenue, NumberOfEmployees, Ownership, TickerSymbol, Description, Rating, Site, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, IsPartner, ChannelProgramName, ChannelProgramLevelName, Jigsaw, JigsawCompanyId, AccountSource, SicDesc, SBQQ__AssetQuantitiesCombined__c, SBQQ__CoTermedContractsCombined__c, SBQQ__CoTerminationEvent__c, SBQQ__ContractCoTermination__c, SBQQ__DefaultOpportunity__c, SBQQ__IgnoreParentContractedPrices__c, SBQQ__PreserveBundle__c, SBQQ__PriceHoldEnd__c, SBQQ__RenewalModel__c, SBQQ__RenewalPricingMethod__c, SBQQ__TaxExempt__c, BillingPlace__c, BillingStreetName__c, BillingStreetNumber__c, BillingStreetNumberExtension__c, BPSAPModel__c, BillingPlaceCode__c, CompanyOwner__c, ConsentSignature__c, CustomerMarking__c, FirstName__c, LastName__c, FiscalCode__c, GlobalMigrationKey__c, IsDocumentAcquired__c, IsMigrated__c, IsWrongFiscalData__c, PrimaryEmail__c, SAPIntegrationID__c, Segment__c, CustomerAccountStatus__c, CategoryCode__c, SalesNumber__c, RegulatedMarketSelfCertification__c, VATGroupStartDate__c, VATGroupEndDate__c, IsVATGroupJoined__c, VATGroup__c, VATNumber__c, FAX__c, VirtualSAPIban__c, CustomerCode__c, RowIdSiebel__c, BillingRegion__c, Gender__c, BillingAddressFormula__c, BillingCityCode__c, BillingStreetCode__c, BillingStreetToponym__c, DataLimitation__c, BirthDate__c, BirthProvince__c, BuildingApartment__c, BuildingFloor__c, BuildingStairCase__c, ContactReason__c, ActiveMonitoring__c, InterestArea__c, InterestProduct__c, BillingAddressIsForeign__c, Activity__c, Age__c, ConvertedDate__c, DegreeOfStudies__c, OriginLeadId__c, Profession__c, Category__c, AccountRating__c, ActiveServicesCtrl__c, ActiveServicesEle__c, ActiveServicesGas__c, ActiveServicesTLR__c, ActiveServicesWaste__c, ActiveServicesWater__c, ActiveServices__c, ChurnkRisk__c, ComplaintRateFormula__c, ComplaintRateNum__c, CreditFormula__c, CustomerLifeCycleEle__c, CustomerLifeCycleEnergy__c, CustomerLifeCycleGas__c, CustomerLifeCycleNonEnergy__c, CustomerLifeCycleTLR__c, CustomerLifeCycleVAS__c, CustomerLifeCycleWaste__c, CustomerLifeCycleWater__c, CustomerLifeCycle__c, DataEnrichmentLastUpdate__c, PraxidiaUpdateDate__c, RecallerFormula__c, Recaller__c, SatisfactionIndexCtrl__c, SatisfactionIndex__c, LegalFormType__c, MobilePhone__c, OtherPhone__c, PhonePrefix__c, BillingIsAddressVerified__c, Code__c, Commodity__c, IsActive__c, MobilePhonePrefix__c, ShippingPlaceCode__c, ShippingPlace__c, CustomerType__c, AssistedCustomer__c, KpiTracking__c, AccountRatingCtrl__c, ChurnkRiskCtrl__c, CreditCheckCalled__c, CreditCheckCtrl__c';  
   //  HDT_QR_Order qrOrder = new HDT_QR_Order();
   // HDT_QR_Case caseQr = new HDT_QR_Case();
   // HDT_QR_Contact contactQr = new HDT_QR_Contact();
   
    public Iterable<Account> start(Database.BatchableContext context) {
        return this.dtos;
    }


    public void execute(Database.BatchableContext context, List<Account> wrapIterable)
    { 
        List<String> listAccountId = new List<String>();
        Map<String,Contact> mapCon = new Map<String,Contact>();
        for(Account a : wrapIterable){
            listAccountId.add(a.id);
        }
        List<Account> getAccountComplete = accQr.getRecordsById(listAccountId,selectStr);
        List<Contact> getContactByAccount = contactQr.getContactsIdByAccountIdList(listAccountId);
        for(Contact c : getContactByAccount) {
            mapCon.put(c.AccountId, c);
        }
        list<Account> accountToUpdate = new List<Account>();
        for(Account a : getAccountComplete){
            accountToUpdate.add(HDT_UTL_Account.massiveRequest(a, mapCon.get(a.id)));
        }
        update accountToUpdate;
    }
    public void finish(Database.BatchableContext context) {
        System.debug('FinishMethodNotNecessariButRequiredForBatch');
    }


}