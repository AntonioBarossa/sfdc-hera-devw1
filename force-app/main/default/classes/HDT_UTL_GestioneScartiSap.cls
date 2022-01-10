public inherited sharing class HDT_UTL_GestioneScartiSap {

    public static Boolean skipPhaseManager(String phase){
        Boolean response = false;
        if (String.isNotBlank(phase)){
            List<HDT_GestioneScartiSap__mdt> rules = [SELECT id FROM HDT_GestioneScartiSap__mdt WHERE Phase__c =:phase AND SkipPhaseManager__c = true WITH SECURITY_ENFORCED];
            response = !rules.isEmpty();
        }
        return response;
    }

    public static List<HDT_GestioneScartiSap__mdt> getRuleFromActivity(Map<String,String> mapFieldValue){ 
        List<HDT_GestioneScartiSap__mdt> response = new List<HDT_GestioneScartiSap__mdt>();
        if (mapFieldValue != null && !mapFieldValue.isEmpty()){
            List<String> partialCondition = new List<String>();
            for (String field : mapFieldValue.keySet()){
                String value = String.escapeSingleQuotes(mapFieldValue.get(field));
                partialCondition.add(field +' = \''+value+'\'');
            }
            String query = 'SELECT Activity__c, CreateActivity__c, ActivityInitialStatus__c,ActivityToClose__c FROM HDT_GestioneScartiSap__mdt WHERE '+String.join(partialCondition, ' AND ')+' WITH SECURITY_ENFORCED';
            response = Database.query(query);
        }
        return response;
    }

}
