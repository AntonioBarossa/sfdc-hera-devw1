public inherited sharing class HDT_LC_ProductAssociation {

    @AuraEnabled
    public static void runProductOptionAssociation(String productOptionId, List<String> recordList, Boolean selectedAll){
        System.debug('>>> productOptionId: ' + productOptionId);
        System.debug('>>> recordList: ' + recordList);
        System.debug('>>> selectedAll: ' + selectedAll);
    }

}