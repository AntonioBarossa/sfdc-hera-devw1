@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_UTL_SegnalazioniCriteria implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {

    global HDT_UTL_SegnalazioniCriteria(){
        return;
    }

    global Boolean evaluate(Object args){//
        Map<String, Object> argsMap = (Map<String, Object>) args;
        //system.debug(json.serialize(args));
        //SObject transition = (SObject) argsMap.get('transition');
        //SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject record = (SObject) argsMap.get('record');
        String oldTransitions = (String) record.get('PhaseStory__c');
        Boolean result = false;
        for(String transition : oldTransitions.split('\\|\\|')){
            result = transition?.containsIgnoreCase('In Attesa Appuntamento');
            if(result){
                break;
            }
        }
        if(method?.equalsIgnoreCase('not')){
            result=!result;
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static list<HDT_SegnalazioniAmbientali__mdt> getMaterialOptions(String operationGroup, String operationType) {        
	    if(STRING.isBlank(operationGroup) || STRING.isBlank(operationType)){    return null;   }

        list<HDT_SegnalazioniAmbientali__mdt> pickoptions = [   
                SELECT Material__c
                FROM HDT_SegnalazioniAmbientali__mdt 
                WHERE 
                OperationGroup__c =:operationGroup
                AND TypeOperation__c =:operationType 
                WITH SECURITY_ENFORCED 
                Order By Material__c
        ];

        return pickoptions;
    }
}