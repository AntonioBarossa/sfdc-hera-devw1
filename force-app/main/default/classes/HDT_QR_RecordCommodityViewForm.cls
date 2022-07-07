public with sharing class HDT_QR_RecordCommodityViewForm {

    public static List<HDT_UserInputFlow__mdt> queryInput(String processType){ //, String commodity){

        List<HDT_UserInputFlow__mdt> userInputFlowList = [
            SELECT Id, FieldsJSON__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType 
            // AND Commodity__c =: commodity // -> Controlla l'ApiName di "Commodity"
            // WITH SECURITY_ENFORCED           
            LIMIT 1
        ];
        return userInputFlowList;
    }
}
