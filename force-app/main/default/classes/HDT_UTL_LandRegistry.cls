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
}
