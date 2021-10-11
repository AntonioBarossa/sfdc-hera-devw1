global inherited sharing class HDT_UTL_CheckPreviousPhase implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {

    global Boolean evaluate(Object args){
        Map<String, Object> argsMap = (Map<String, Object>) args;
        //system.debug(json.serialize(args));
        //SObject transition = (SObject) argsMap.get('transition');
        //SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject record = (SObject) argsMap.get('record');
        String oldTransitions = (String) record.get('PhaseStory__c');
        String checkPhase = method.replaceAll('_', ' ');
        Boolean result = false;
        try{
            if(String.isNotBlank(oldTransitions)){
                result=oldTransitions.split('\\|\\|')[0].trim().startsWithIgnoreCase(checkPhase);
            }
        }catch(Exception e){
            result=false;
        }
        return result;
    }
}
