public with sharing class HDT_LC_InterventionDependency {

    @AuraEnabled
    public static Map <String, Object> generatePicklistsData(String city){
        Map <String, Object> result = new Map <String, Object>();
        
        result.put('operationGroups', new Set<Object>());
        result.put('operationTypes', new Map<String, Set<Object>>());
        result.put('materials', new Map<String, Set<Object>>());

        List<EquipmentAdministration__c> quadSignals = [SELECT 
                                                            OperationGroup__c, toLabel(OperationGroup__c) groupLabel, 
                                                            OperationType__c, toLabel(OperationType__c) typeLabel, 
                                                            Material__c, toLabel(Material__c) materialLabel, Id
                                                        FROM EquipmentAdministration__c 
                                                        WHERE 
                                                            IsActive__c = true 
                                                            AND IsQuadruplet__c = true 
                                                            AND City__c =: city
                                                        WITH SECURITY_ENFORCED];

        if (quadSignals.isEmpty()) {
            throw new AuraHandledException('Non sono state trovate configurazioni per il Comune selezionato.');
        }

        for (EquipmentAdministration__c quadSignal : quadSignals) {

            String typeKey = quadSignal.OperationGroup__c;
            String materialsKey = quadSignal.OperationGroup__c + quadSignal.OperationType__c;

            Object ig = (Object) new Map<String, String> {'value' => quadSignal.OperationGroup__c, 'label' => STRING.valueOf(quadSignal.get('groupLabel'))};
            Object it = (Object) new Map<String, String> {'value' => quadSignal.OperationType__c, 'label' => STRING.valueOf(quadSignal.get('typeLabel'))};
            Object ma = (Object) new Map<String, String> {'value' => quadSignal.Material__c, 'label' => STRING.valueOf(quadSignal.get('materialLabel'))};
            
            ((Set<Object>) result.get('operationGroups')).add(ig);
            
            if (((Map <String, Set<Object>>) result.get('operationTypes')).containsKey(typeKey)) {
                ((Map <String, Set<Object>>) result.get('operationTypes')).get(typeKey).add(it);
            } else {
                ((Map <String, Set<Object>>) result.get('operationTypes')).put(typeKey, new Set<Object>{it});
            }

            if (((Map <String, Set<Object>>) result.get('materials')).containsKey(materialsKey)) {
                ((Map <String, Set<Object>>) result.get('materials')).get(materialsKey).add(ma);
            } else {
                ((Map <String, Set<Object>>) result.get('materials')).put(materialsKey, new Set<Object>{ma});
            }

        }

        return result;
    }
}