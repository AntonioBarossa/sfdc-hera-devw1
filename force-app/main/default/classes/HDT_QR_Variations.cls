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



    public static List<ServicePoint__c> queryServicePoint(String accountId, String commodity, String servicePointId){

        List<ServicePoint__c> toReturnList = new List<ServicePoint__c>();
        try{
            toReturnList = [SELECT Id 
            FROM ServicePoint__c
            WHERE Id != :servicePointId
            AND CommoditySector__c = :commodity
            AND Account__c = :accountId
            AND Resident__c = true
            WITH SECURITY_ENFORCED];
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        return toReturnList;

    }


    public static List<Case> queryOtherCases(List<Id> servicePointIds, String caseId){

        List<Case> toReturnList = new List<Case>();
        try{
            toReturnList = [SELECT Id 
            FROM Case
            WHERE Id IN :servicePointIds
            AND Id != :caseId
            AND Resident__c = false
            WITH SECURITY_ENFORCED];
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        return toReturnList;

    }

    public static Case getCaseInfo(String caseId){

        Case currentCase = new Case();

        try{

            currentCase = [SELECT AccountId,
            ServicePoint__c,
            CommodityFormula__c
            FROM Case
            WHERE Id = :caseId
            WITH SECURITY_ENFORCED
            LIMIT 1];

        }catch(Exception e){

            System.debug(e.getMessage());

        }

        return currentCase;

    }


}