public inherited sharing class HDT_QR_Variations {

    public static Boolean queryConsistencyTable(String recordId, String useCategory, String supplyType, String servicePointType){

        String taxes = [SELECT Taxes__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED].Taxes__c;

        List<HDT_MarkingConsistency__mdt> consistencyRecords = new List<HDT_MarkingConsistency__mdt>();

        if(Schema.SObjectType.HDT_MarkingConsistency__mdt.isAccessible()
        && Schema.SObjectType.HDT_MarkingConsistency__mdt.fields.SupplyType__c.isAccessible()
        && Schema.SObjectType.HDT_MarkingConsistency__mdt.fields.ImplantType__c.isAccessible()
        && Schema.SObjectType.HDT_MarkingConsistency__mdt.fields.Taxes__c.isAccessible()
        && Schema.SObjectType.HDT_MarkingConsistency__mdt.fields.UseCategory__c.isAccessible()){

            consistencyRecords = [
                SELECT Id
                FROM HDT_MarkingConsistency__mdt
                WHERE SupplyType__c = :supplyType
                    AND ImplantType__c = :servicePointType
                    AND Taxes__c = :taxes
                    AND UseCategory__c = :useCategory
                WITH SECURITY_ENFORCED
            ];

        } else {

            return false;

        }

        return consistencyRecords.size() > 0;



    }


}
