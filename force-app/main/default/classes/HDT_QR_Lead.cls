/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 21/04/2021
* @description HDT_QR_Lead 
* @history Sabina Levonja – 21/04/2021 – created class 
*/
public  inherited sharing class HDT_QR_Lead {
    
    public Lead getRecordById(String id) {
        
        List<Lead> leads = [SELECT Id, FirstName, LastName, IndividualId, Birthdate__c, Gender__c, Birthcity__c, Country, State, City, PostalCode, Street, StreetName__c, StreetNumber__c, CityCode__c, 
            VATNumber__c, StreetNumberExtension__c, StreetCode__c, PlaceCode__c, Place__c, IsAddressVerified__c, CreatedBy.LoginChannel__c FROM Lead WHERE Id = :id WITH SECURITY_ENFORCED];

        return leads[0];
    }

    public List<Lead> getRecordsById(List<String> ids) {
        
        String query = 'SELECT  Firstname,LastName,IndividualId,Consenso_IBM_Unica__c, CompanyOwner__c FROM Lead WHERE Id IN :ids WITH SECURITY_ENFORCED';
        List<Lead> leads = Database.query(String.escapeSingleQuotes(query));

        return leads;

    }

           /**
     * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
     * @description Get Contact Point records by Id
     * @param String individualId Id of the individual to filter the Leads
     * @param String fields fields to retrieve separated by ,
     */
    public List<Lead> getRecordByIndividual(String individualId, String fields) {

        String query = 'SELECT '+ fields +
                ' FROM Lead WHERE IndividualId = :individualId WITH SECURITY_ENFORCED';

        return Database.query(String.escapeSingleQuotes(query));

    }
    public static List<Lead> getCurrentRecords(Lead CurrentLead ){
        return [SELECT Id, IsDeleted, MasterRecordId, LastName, FirstName, Salutation, Name, RecordTypeId, Title, Company, 
        Street, City, State, PostalCode, Country, Latitude, Longitude, GeocodeAccuracy, Address, Phone, MobilePhone, Fax, 
        Email, Website, PhotoUrl, Description, LeadSource, Status, Industry, Rating, AnnualRevenue, NumberOfEmployees,
        OwnerId, HasOptedOutOfEmail, IsConverted, ConvertedDate, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, 
        IsUnreadByOwner, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, DoNotCall, 
        HasOptedOutOfFax, LastViewedDate, LastReferencedDate, LastTransferDate, PartnerAccountId, Jigsaw, JigsawContactId, 
        EmailBouncedReason, EmailBouncedDate, IndividualId, SICCode__c, CurrentGenerators__c, NumberOfLocations__c, Company__c, 
        CompanyOwner__c, CustomerCode__c, GlobalMigrationKey__c, IsMigrated__c, RetentionStartDate__c, ContactDate__c, FiscalCode__c, 
        IsWrongFiscalData__c, Contact__c, VATNumber__c, isSandboxRecord__c, RowIdSiebel__c, et4ae5__HasOptedOutOfMobile__c, 
        et4ae5__Mobile_Country_Code__c, KeyIBMUnica__c, SubscriptionCategory__c, Gender__c, Nationality__c, ProductCategory__c, 
        AtecoDescription__c, FileImportField1__c, FileImportField2__c, FileImportField3__c, FileImportField4__c, FileImportField5__c,
        FileImportField6__c, AgeGroup__c, Age__c, CodIstat__c, CollectionAgency__c, CollectionOperator__c, IsAddressVerified__c, 
        consumption__c, InterestProduct__c, LeadReceptionDate__c, LeadValidityEndDate__c, NonConversionReason__c, Place__c, Portion__c, 
        SourceAgency__c, SourceDetail__c, Activity__c, CommerciaId__c, DegreeOfStudies__c, PhonePrefix__c, Sigla__c, AddressIstatCode__c,
        CampaignSource__c, Category__c, MobilePhonePrefix__c, Birthcity__c, Birthdate__c, CityCode__c, ContactReason__c, Profession__c, 
        Region__c, StreetCode__c, StreetName__c, StreetNumberExtension__c, StreetNumber__c, CustomerMarking__c, InterestArea__c, PlaceCode__c,
        WebFormField01__c, WebFormField02__c, WebFormField03__c, WebFormField04__c, WebFormField05__c, WebFormField06__c, WebFormField07__c,
        WebFormField08__c, WebFormField09__c, WebFormField10__c, WebFormField11__c, WebFormField12__c, WebFormField13__c, WebFormField14__c, 
        WebFormField15__c, WebFormField16__c, WebFormField17__c, WebFormField18__c, WebFormField19__c, WebFormField20__c, WebFormField21__c,
        WebFormField22__c, WebFormField23__c, WebFormField24__c, WebFormField25__c, WebFormField26__c, WebFormField27__c, WebFormField28__c,
        WebFormField29__c, WebFormField30__c, WebFormField31__c, WebFormField32__c, WebFormField33__c, WebFormField34__c, WebFormField35__c,
        WebFormField36__c, WebFormField37__c, WebFormField38__c, WebFormField39__c, WebFormField40__c, isSendToReitek__c,individual.MarketingPrivacy__c,
        individual.MarketingPrivacyVersion__c,individual.PrivacyMarketingChoiceDate__c,individual.PrivacyMarketingChoiceSource__c,individual.MarketingCompanyConsent__c,
        individual.PrivacyMarketingConsentInitiative__c,individual.ProfilingPrivacy__c,individual.ProfilingPrivacyVersion__c,individual.PrivacyProfilingChoiceDate__c,
        individual.PrivacyProfilingChoiceSource__c,individual.ProfilingCompanyConsent__c,individual.PrivacyProfilingConsentInitiative__c  FROM Lead 
        WHERE FirstName=:CurrentLead.FirstName AND LastName=:CurrentLead.LastName AND CompanyOwner__c=:CurrentLead.CompanyOwner__c AND (MobilePhone=:CurrentLead.MobilePhone OR Phone =: CurrentLead.Phone OR Email=:CurrentLead.Email )
        WITH SECURITY_ENFORCED];
    }

    /*public static List<Lead> getCurrentRecords(HDT_UTL_ProcessLead.HDT_WRP_LeadDataForRetrieve sets){
        return [
            SELECT Id, IsDeleted, MasterRecordId, LastName, FirstName, Salutation, Name, RecordTypeId, Title, Company, 
                   Street, City, State, PostalCode, Country, Latitude, Longitude, GeocodeAccuracy, Address, Phone, MobilePhone, Fax, 
                   Email, Website, PhotoUrl, Description, LeadSource, Status, Industry, Rating, AnnualRevenue, NumberOfEmployees,
                   OwnerId, HasOptedOutOfEmail, IsConverted, ConvertedDate, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, 
                   IsUnreadByOwner, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, DoNotCall, 
                   HasOptedOutOfFax, LastViewedDate, LastReferencedDate, LastTransferDate, PartnerAccountId, Jigsaw, JigsawContactId, 
                   EmailBouncedReason, EmailBouncedDate, IndividualId, SICCode__c, CurrentGenerators__c, NumberOfLocations__c, Company__c, 
                   CompanyOwner__c, CustomerCode__c, GlobalMigrationKey__c, IsMigrated__c, RetentionStartDate__c, ContactDate__c, FiscalCode__c, 
                   IsWrongFiscalData__c, Contact__c, VATNumber__c, isSandboxRecord__c, RowIdSiebel__c, et4ae5__HasOptedOutOfMobile__c, 
                   et4ae5__Mobile_Country_Code__c, KeyIBMUnica__c, SubscriptionCategory__c, Gender__c, Nationality__c, ProductCategory__c, 
                   AtecoDescription__c, FileImportField1__c, FileImportField2__c, FileImportField3__c, FileImportField4__c, FileImportField5__c,
                   FileImportField6__c, AgeGroup__c, Age__c, CodIstat__c, CollectionAgency__c, CollectionOperator__c, IsAddressVerified__c, 
                   consumption__c, InterestProduct__c, LeadReceptionDate__c, LeadValidityEndDate__c, NonConversionReason__c, Place__c, Portion__c, 
                   SourceAgency__c, SourceDetail__c, Activity__c, CommerciaId__c, DegreeOfStudies__c, PhonePrefix__c, Sigla__c, AddressIstatCode__c,
                   CampaignSource__c, Category__c, MobilePhonePrefix__c, Birthcity__c, Birthdate__c, CityCode__c, ContactReason__c, Profession__c, 
                   Region__c, StreetCode__c, StreetName__c, StreetNumberExtension__c, StreetNumber__c, CustomerMarking__c, InterestArea__c, PlaceCode__c,
                   WebFormField01__c, WebFormField02__c, WebFormField03__c, WebFormField04__c, WebFormField05__c, WebFormField06__c, WebFormField07__c,
                   WebFormField08__c, WebFormField09__c, WebFormField10__c, WebFormField11__c, WebFormField12__c, WebFormField13__c, WebFormField14__c, 
                   WebFormField15__c, WebFormField16__c, WebFormField17__c, WebFormField18__c, WebFormField19__c, WebFormField20__c, WebFormField21__c,
                   WebFormField22__c, WebFormField23__c, WebFormField24__c, WebFormField25__c, WebFormField26__c, WebFormField27__c, WebFormField28__c,
                   WebFormField29__c, WebFormField30__c, WebFormField31__c, WebFormField32__c, WebFormField33__c, WebFormField34__c, WebFormField35__c,
                   WebFormField36__c, WebFormField37__c, WebFormField38__c, WebFormField39__c, WebFormField40__c, isSendToReitek__c,individual.MarketingPrivacy__c,
                   individual.MarketingPrivacyVersion__c,individual.PrivacyMarketingChoiceDate__c,individual.PrivacyMarketingChoiceSource__c,individual.MarketingCompanyConsent__c,
                   individual.PrivacyMarketingConsentInitiative__c,individual.ProfilingPrivacy__c,individual.ProfilingPrivacyVersion__c,individual.PrivacyProfilingChoiceDate__c,
                   individual.PrivacyProfilingChoiceSource__c,individual.ProfilingCompanyConsent__c,individual.PrivacyProfilingConsentInitiative__c
        FROM Lead 
        WHERE FirstName IN :sets.firstNameSet
        AND LastName = :sets.lastNameSet
        AND CompanyOwner__c = :sets.companyOwnerSet
        AND (
             MobilePhone = :sets.mobilePhoneSet
             OR Phone = :sets.phoneSet
             OR Email = :sets.emailSet
            )
        //WITH SECURITY_ENFORCED
        ];
    }*/

}