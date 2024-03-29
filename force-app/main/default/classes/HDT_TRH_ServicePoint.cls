public with sharing class HDT_TRH_ServicePoint extends HDT_TRH_TriggerHandler{
    public override void beforeUpdate(){
        HDT_UTL_GlobaMigrationKey.setGlobalMigrationKey(Trigger.new, Trigger.oldMap);
        this.manageSupplyStreet(Trigger.oldMap, trigger.new);
        HDT_UTL_ServicePoint.blockblankonfield(trigger.old,trigger.new);
    }
    
    public override void beforeInsert(){
        this.manageSupplyStreet(Trigger.oldMap, trigger.new);
        this.handleGlobalMigrationKey(Trigger.new);
    }

    public void manageSupplyStreet(Map<Id,SObject> oldObjMap, List<ServicePoint__c> servicePointList){
        for(ServicePoint__c servicePoint : servicePointList){
            if((servicePoint.SupplyStreet__c == null || servicePoint.SupplyStreet__c == '') &&
               (servicePoint.SupplyStreetName__c != null && servicePoint.SupplyStreetName__c != '')){
                servicePoint.SupplyStreet__c = servicePoint.SupplyStreetName__c;
            }
            else if((servicePoint.SupplyStreetName__c == null || servicePoint.SupplyStreetName__c == '') &&
                    (servicePoint.SupplyStreet__c != null && servicePoint.SupplyStreet__c != '')){
                servicePoint.SupplyStreetName__c = servicePoint.SupplyStreet__c;
            }
            if(oldObjMap != null && !String.isBlank(servicePoint.SupplyStreet__c) && !servicePoint.SupplyStreet__c.equalsIgnoreCase((String) oldObjMap.get(servicePoint.Id).get('SupplyStreet__c'))){
                servicePoint.SupplyStreetName__c = servicePoint.SupplyStreet__c;
                servicePoint.SupplyCityCode__c = servicePoint.SupplySAPCityCode__c;
                servicePoint.SupplyStreetCode__c = servicePoint.SupplySAPStreetCode__c;
            }
            if ('Energia Elettrica'.equalsIgnoreCase(servicePoint.CommoditySector__c) && String.isNotBlank(servicePoint.ServicePointCode__c)){
                servicePoint.ServicePointCode__c = servicePoint.ServicePointCode__c.toUpperCase();
            }
        }
    }
    
    private void handleGlobalMigrationKey(List<ServicePoint__c> servicePointList){
        for(ServicePoint__c servicePoint : servicePointList){
            if(String.isNotBlank(servicePoint.SAPImplantCode__c)){
                servicePoint.GlobalMigrationKey__c = 'SP_'+servicePoint.SAPImplantCode__c;
            }
        }
    }
}
