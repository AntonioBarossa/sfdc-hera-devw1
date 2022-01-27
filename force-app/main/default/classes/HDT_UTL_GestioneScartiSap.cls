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
            List<HDT_GestioneScartiSap__mdt> allRules = HDT_GestioneScartiSap__mdt.getAll().values();
            Integer sizeRule = 0;
            //Questo For aggiunge alla response le regole con il più alto numero di campi uguali
            for (HDT_GestioneScartiSap__mdt rule : allRules){
                List<String> ruleKey = new List<String>(); 
                for (String field : mapFieldValue.keySet()){
                    String valueToSearch = mapFieldValue.get(field);
                    if (valueToSearch.equalsIgnoreCase((String)rule.get(field))){
                        ruleKey.add(field);
                    }
                }
                Integer newSizeRule = ruleKey.size();
                if (!ruleKey.isEmpty() && newSizeRule >= sizeRule){
                    if (newSizeRule > sizeRule){
                        sizeRule = newSizeRule;
                        response = new List<HDT_GestioneScartiSap__mdt>();
                    }
                    response.add(rule);
                }
            }
        }
        return response;
    }

}
