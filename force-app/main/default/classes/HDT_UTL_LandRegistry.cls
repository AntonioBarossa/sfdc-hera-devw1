/*
    @Author:  Carmine Scalise (carmine.scalise@webresults.it)
    @CreatedDate:  9/05/2022
*/

public with sharing class HDT_UTL_LandRegistry {

    @AuraEnabled
    public static list<LandRegistry__c> retrieveLandRegistryTable(Id caseId, Id orderId, Id servicePointId) {
        system.debug('pratica caseId: ' + caseId);
        system.debug('pratica orderId: ' + orderId);
        system.debug('pratica servicePointId: ' + servicePointId);
        list<LandRegistry__c> lndRgTable = new list<LandRegistry__c>();
        HDT_QR_LandRegistry qrClass = new HDT_QR_LandRegistry();
        Id rtIdPraticaTARI = Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByName().get('Dati Catastali Pratica TARI').getRecordTypeId();

        list<LandRegistry__c> praticaData = new list<LandRegistry__c>();
        if(caseId != null) praticaData = qrClass.getPraticaTARILandRegistryByCaseIds(new list<Id> {caseId});
        else if(orderId != null) praticaData = qrClass.getPraticaTARILandRegistryByOrderIds(new list<Id> {orderId});
        system.debug('praticaData: ' + JSON.serialize(praticaData));
        if(!praticaData.isEmpty()) return praticaData;

        list<LandRegistry__c> originData = qrClass.getTARILandRegistryByServicePointIds(new list<Id> {servicePointId});
        for(LandRegistry__c curOriginRecord : originData){
            LandRegistry__c resultLR;
            resultLR = curOriginRecord.clone(false, true, false, false);
            resultLR.RecordTypeId = rtIdPraticaTARI;
            resultLR.ServicePoint__c = null;
            if(caseId != null) resultLR.Case__c = caseId;
            if(orderId != null) resultLR.Order__c = orderId;
            system.debug('pratica record: ' + JSON.serialize(resultLR));
            lndRgTable.add(resultLR);
        }
        insert lndRgTable;
        return lndRgTable;
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