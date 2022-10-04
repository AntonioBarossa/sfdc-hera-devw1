/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 04-10-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidDebugStatements , PMD.ApexCRUDViolation')
public with sharing class HDT_LC_MaterialSelection {

    public with sharing class HDT_WRP_Data{
        @AuraEnabled public List<VolumetricEstimate__c> volumetricEstimate {get;set;}
        @AuraEnabled public List<VolumetricEstimate__c> preselectedValues {get;set;}
        @AuraEnabled public List<Id> preselectedKeys {get;set;}

        HDT_WRP_Data(){return;}
        public HDT_WRP_Data(List<VolumetricEstimate__c> volumetricEstimate, Map<Id,VolumetricEstimate__c> preselectedValuesMap){
            this.volumetricEstimate=volumetricEstimate;
            this.preselectedValues=preselectedValuesMap.values();
            this.preselectedKeys=new List<Id>(preselectedValuesMap.keySet());
        }
    }
    
    public static List<VolumetricEstimate__c> getVolumetricEstimate() {

        return [ 
                SELECT Id, 
                Description__c,
                CubicMeters__c,
                Typology__c
                FROM VolumetricEstimate__c 
                WITH SECURITY_ENFORCED
                ORDER BY Description__c 
        ];

    }

    public static Map<Id,VolumetricEstimate__c> getVolumetricEstimateByCaseId(String caseId) {
        return new Map<Id,VolumetricEstimate__c>( [Select Id, Description__c,CubicMeters__c, Typology__c FROM VolumetricEstimate__c WHERE Id IN (SELECT VolumetricEstimate__c 
        FROM CaseVolumetricaJunction__c 
        WHERE Case__c =:caseId) WITH SECURITY_ENFORCED ]);
    }

    @AuraEnabled
    public static HDT_WRP_Data getTables(String caseId){
        return new HDT_WRP_Data(getVolumetricEstimate(), getVolumetricEstimateByCaseId(caseId));
    }

    @AuraEnabled
    public static List<CaseVolumetricaJunction__c> createJunctionObj(String caseId, List<String> volumetricEsimateIds){
        
        List<CaseVolumetricaJunction__c> obj = [SELECT Id
                                                FROM CaseVolumetricaJunction__c 
                                                WHERE Case__c =:caseId
                                                WITH SECURITY_ENFORCED];

        if(!obj.isEmpty()){
            try {
                System.debug(LoggingLevel.DEBUG ,'deleted object ' + obj);
                delete obj;
            } catch (DmlException e) {
                System.debug(LoggingLevel.DEBUG, e.getMessage());
            }
        }


        List<CaseVolumetricaJunction__c> caseVolumetricaJunctionList=new List<CaseVolumetricaJunction__c>();

		for (String volumetric: volumetricEsimateIds){

			CaseVolumetricaJunction__c caseVolumetricaJunction = new CaseVolumetricaJunction__c();
            caseVolumetricaJunction.Case__c = caseId;
            caseVolumetricaJunction.VolumetricEstimate__c = volumetric;
			caseVolumetricaJunctionList.add(caseVolumetricaJunction);

		}

        HDT_UTL_DatabaseService.insertSObject(caseVolumetricaJunctionList);
        System.debug(LoggingLevel.DEBUG, 'inserted object ' + caseVolumetricaJunctionList);
        return caseVolumetricaJunctionList;
    }    

}