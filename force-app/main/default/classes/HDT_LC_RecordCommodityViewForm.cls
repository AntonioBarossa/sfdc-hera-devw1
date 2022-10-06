/**
* @author Carmine Scalise (carmine.scalise@webresults.it)
* @date 06/07/2022
* @description HDT_LC_RecordCommodityViewForm
* @history 
*/
public with sharing class HDT_LC_RecordCommodityViewForm {
    
    @AuraEnabled
    public static String getFields(String recordId) {

        Case myCase = [
            SELECT Id, Type, Commodity__c
            FROM Case
            WHERE Id =: recordId            
            LIMIT 1
        ];

        System.debug('### HDT_LC_RecordCommodityViewForm -> myCase ='+ myCase);
        
        String userInputFlow;        
        String qField = 'Id, FieldsJSON__c';
        String sObjName = 'HDT_UserInputFlow__mdt';
        List<HDT_UserInputFlow__mdt> userInputFlowList = HDT_QR_GenericQuery.getGenericRecords(qField, sObjName, 'ProcessType__c =\''+myCase.Type+'\' AND Commodity__c =\''+myCase.Commodity__c+'\'');

        if(userInputFlowList.size() > 0 ){
            System.Debug('### HDT_LC_RecordCommodityViewForm -> userInputFlowList = '+ userInputFlowList);
            userInputFlow = JSON.serialize(userInputFlowList[0]);
            System.Debug('### HDT_LC_RecordCommodityViewForm -> userInputFlow = '+ userInputFlow);
        }
        return userInputFlow;
    }
}