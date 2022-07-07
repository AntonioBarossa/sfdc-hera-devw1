public with sharing class HDT_LC_RecordCommodityViewForm {
    
    @AuraEnabled
    public static String getFields(String processType){ //, String commodity){

        String userInputFlow;
        List<HDT_UserInputFlow__mdt> userInputFlowList = HDT_QR_RecordCommodityViewForm.queryInput(processType); //, commodity);

        if(userInputFlowList.size() > 0 ){
            userInputFlow = JSON.serialize(userInputFlowList);
        }
        return userInputFlow;
    }
}
