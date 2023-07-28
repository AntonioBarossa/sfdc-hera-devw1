/*
    @Author:        Davide Viola
    CreatedDate:    09/11/2021
*/

@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_ServiceCatalogFieldFilter implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {

    global Boolean evaluate(Object args) {

        Map<String, Object> argsMap = (Map<String, Object>) args;
        SObject record = (sObject) argsMap.get('record');
        String method = (String) argsMap.get('method');
        String objectType = record.Id.getSObjectType().getDescribe().getName();
        Boolean res = true;
        List<String> markingFilters = new List<String>{'BP TARI NG AAA','BP TARIP','BP TARI NG MMS'};

        if(objectType != 'Case'){
            if(method != 'tariFilter'){
                res = (String.isNotBlank((String)record.get('CustomerMarking__c')) && markingFilters.contains((String)record.get('CustomerMarking__c'))) ? !(Boolean)record.get('IsWrongFiscalData__c') : (Boolean)record.get('IsDigitalMarking__c') && !(Boolean)record.get('IsWrongFiscalData__c');
            }
            else if(String.isNotBlank((String)record.get('CustomerMarking__c')) && markingFilters.contains((String)record.get('CustomerMarking__c'))){
                res = !(Boolean)record.get('IsWrongFiscalData__c');
            }
            else{
                res = false;
            }
        }
        return res;
    }
}