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
            // siccome gli account TARING non hanno isDigitalMarking, vale la pena aggiungere un filtro anche sul marking
            if(method != 'tariFilter'){
                res = (Boolean)record.get('IsDigitalMarking__c') && !(Boolean)record.get('IsWrongFiscalData__c') && !markingFilters.contains((String)record.get('CustomerMarking__c'));
            }
            else {
                res = !(Boolean)record.get('IsWrongFiscalData__c') && ((Boolean)record.get('IsDigitalMarking__c') || markingFilters.contains((String)record.get('CustomerMarking__c')));
            }

        }



        return res;
    }
}