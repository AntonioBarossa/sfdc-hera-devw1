/**
* @author Carmine Scalise (carmine.scalise@webresults.it)
* @date 06/07/2022
* @description HDT_QR_RecordCommodityViewForm
* @history 
*/
public with sharing class HDT_QR_RecordCommodityViewForm {

    public static List<HDT_UserInputFlow__mdt> queryInput(String processType, String commodity){

        System.Debug('### HDT_QR_RecordCommodityViewForm -> processType = '+ processType);
        System.Debug('### HDT_QR_RecordCommodityViewForm -> commodity = '+ commodity);
        List<HDT_UserInputFlow__mdt> userInputFlowList = [
            SELECT Id, FieldsJSON__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType 
            AND Commodity__c =: commodity
            WITH SECURITY_ENFORCED           
            LIMIT 1
        ];
        System.Debug('### HDT_QR_RecordCommodityViewForm -> userInputFlowList = '+ userInputFlowList[0].FieldsJSON__c);
        return userInputFlowList;
    }
}
