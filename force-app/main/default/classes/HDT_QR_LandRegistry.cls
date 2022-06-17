/*
    @Author:  Carmine Scalise (carmine.scalise@webresults.it)
    @CreatedDate:  10/05/2022
*/

public inherited sharing class HDT_QR_LandRegistry {

    public list<LandRegistry__c> getTARILandRegistryByServicePointIds(list<Id> listId) {
        Id rtIdTARI = Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByName().get('Dati Catastali TARI').getRecordTypeId();
	    list<LandRegistry__c> ldRegistry = [
            SELECT Id, CodeMissingRegistryData__c, DestinationUsage__c, RegistryCity__c, RegistryCityCode__c, 
            LegalCity__c, Province__c, UnitType__c, UrbanSection__c, Sheet__c, ParticleSheet__c, Subaltern__c, 
            RegistryCategory__c, RegistrySurface__c, Title__c, ServicePoint__r.ServicePointCode__c
	        FROM LandRegistry__c 
	        WHERE ServicePoint__c IN :listId
	        AND RecordTypeId = :rtIdTARI
        ];
        return ldRegistry;
    }
}
