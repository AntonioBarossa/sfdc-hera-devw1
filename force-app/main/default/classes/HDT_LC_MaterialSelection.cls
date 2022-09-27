/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 26-09-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_LC_MaterialSelection {
    
    @AuraEnabled(Cacheable=true)
    public static List <VolumetricEstimate__c> getVolumetricEstimate() {

        return [ 
                SELECT Id, 
                Description__c,
                Cubic_Meters__c,
                Typology__c
                FROM VolumetricEstimate__c 
                WITH SECURITY_ENFORCED
        ];

    }

}