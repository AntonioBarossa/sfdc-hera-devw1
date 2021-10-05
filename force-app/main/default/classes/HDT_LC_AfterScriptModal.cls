public inherited sharing class HDT_LC_AfterScriptModal {
    
    private static HDT_UTL_HelperMethods helper = new HDT_UTL_HelperMethods();

    @AuraEnabled
    public static Map<String,Object> initPostSaleAction(){

        Map<String,Object> result = new Map<String,Object>();

        result.put('isCommunity', helper.checkCommunityLogin());

        return result;
    }

}
