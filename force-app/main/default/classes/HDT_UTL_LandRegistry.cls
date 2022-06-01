/*
    @Author:  Carmine Scalise (carmine.scalise@webresults.it)
    @CreatedDate:  9/05/2022
*/

public with sharing class HDT_UTL_LandRegistry {

    @AuraEnabled
    public static list<LandRegistry__c> retrieveLandRegistry(list<Id> servicePointIds) {

        HDT_QR_LandRegistry qrClass = new HDT_QR_LandRegistry();
        return qrClass.getLandRegistryByServicePointIds(servicePointIds);
    }

    @AuraEnabled
    public static list<CadastralCategories__c> getCadastralCategories() {     
	    list<CadastralCategories__c> cdCategories = [
            SELECT Id, Name, Categoria__c
	        FROM CadastralCategories__c 
        ];
        return cdCategories;
    }

    @AuraEnabled
    public static list<Cities__c> getCities() {        
	    list<Cities__c> cities = [
            SELECT Id, Comune_catastale__c, Codice_comune_catastale__c, Comune_amministrativo__c, Provincia__c, TARI_Gestita__c
	        FROM Cities__c 
        ];
        return cities;
    }

}
