public with sharing class HDT_QR_Equipment {
    

    public List<AggregateResult> getAggregatesInfosByCodes(Set<String> equipmentCodes, Id contractId){
        return  
            [   
                SELECT MIN(Volumetry__c) volMin, MAX(Volumetry__c) volMax 
                FROM Equipment__c 
                WHERE 
                    Contract__c = :contractId AND
                    EquipmentCode__c IN :equipmentCodes
                WITH SECURITY_ENFORCED Group By Contract__c
            ];
    }

    public Map<String, Equipment__c> getEquipmentByCodes(Set<String> equipmentCodes, Id contractId){
        Map<String, Equipment__c> mapToReturn = new Map<String, Equipment__c>();

        for(Equipment__c eq :   [   
                                    SELECT Volumetry__c, EquipmentCode__c
                                    FROM Equipment__c 
                                    WHERE 
                                        Contract__c = :contractId AND
                                        EquipmentCode__c IN :equipmentCodes
                                    WITH SECURITY_ENFORCED
                                ]
        ){
            mapToReturn.put(eq.EquipmentCode__c, eq);
        }
         
        return mapToReturn;
    }
}