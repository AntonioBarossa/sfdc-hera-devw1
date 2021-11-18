/*
    @Author:        Davide Viola
    CreatedDate:    09/11/2021
*/

@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_ServiceCatalogFieldFilter implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {

    global Boolean evaluate(Object args) {

        Map<String, Object> argsMap = (Map<String, Object>) args;
        SObject record = (sObject) argsMap.get('record');
        String objectType = record.Id.getSObjectType().getDescribe().getName();
        Boolean res = true;

        if(objectType != 'Case'){
            res = (Boolean)record.get('IsDigitalMarking__c') && !(Boolean)record.get('IsWrongFiscalData__c');
        }

        return res;
    }
}