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

        System.debug('### myCase'+ myCase);
        String userInputFlow;
        List<HDT_UserInputFlow__mdt> userInputFlowList = HDT_QR_RecordCommodityViewForm.queryInput(myCase.Type, myCase.Commodity__c);

        if(userInputFlowList.size() > 0 ){
            System.Debug('### userInputFlowList '+ userInputFlowList);
            userInputFlow = JSON.serialize(userInputFlowList[0].FieldsJSON__c);
            System.Debug('### userInputFlow '+ userInputFlow);
        }
        return userInputFlow;
    }
}
