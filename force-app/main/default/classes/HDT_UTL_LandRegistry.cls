/*
    @Author:  Carmine Scalise (carmine.scalise@webresults.it)
    @CreatedDate:  9/05/2022
*/

public with sharing class HDT_UTL_LandRegistry {

    @AuraEnabled
    public static list<LandRegistry__c> retrieveLandRegistryTable(list<Id> servicePointIds) {
        HDT_QR_LandRegistry qrClass = new HDT_QR_LandRegistry();
        return qrClass.getTARILandRegistryByServicePointIds(servicePointIds);
    }

    @AuraEnabled
    public static list<LandRegistry__c> retrieveLandRegistry(list<Id> ids) {
        HDT_QR_LandRegistry qrClass = new HDT_QR_LandRegistry();
        return qrClass.getTARILandRegistryById(ids);
    }
    
    @AuraEnabled
    public static list<CadastralCategories__c> getCadastralCategories() {     
	    list<CadastralCategories__c> cdCategories = [ SELECT Id, Category__c, Description__c FROM CadastralCategories__c WITH SECURITY_ENFORCED];
        return cdCategories;
    }
    
    @AuraEnabled
    public static list<CityTechnicalData__c> getCities() {        
	    list<CityTechnicalData__c> cities = [ SELECT Id, CadastralCity__c, CityCode__c, Province__c FROM CityTechnicalData__c WITH SECURITY_ENFORCED];
        return cities;
    } 
}