public with sharing class HDT_UTL_LandRegistry {

    @AuraEnabled
    public static list<LandRegistry__c> retrieveLandRegistryByServicePointId(set<Id> setId) { 

	    list<LandRegistry__c> ldRegistry = [
            SELECT Id, CodeMissingRegistryData__c, DestinationUsage__c, RegistryCity__c, RegistryCityCode__c, 
            LegalCity__c, Province__c, UnitType__c, UrbanSection__c, Sheet__c, ParticleSheet__c, Subaltern__c, 
            RegistryCategory__c, RegistrySurface__c, Title__c // MANCA --> Numero componenti nucleo familiare!
	        FROM LandRegistry__c 
	        WHERE ServicePoint__c IN: setId
	        //AND RecordType = HDT_RT_DatiCatastali_TARI. --> Da aggiungere filtro per rc
        ];
        return ldRegistry;
    }
}
