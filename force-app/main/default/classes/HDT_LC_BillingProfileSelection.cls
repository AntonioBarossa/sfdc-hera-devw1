public with sharing class HDT_LC_BillingProfileSelection {
    private static HDT_QR_BillingProfileSelection getterMethods = new HDT_QR_BillingProfileSelection();

    @AuraEnabled(cacheable = true)
    public static String getConfiguration(String search){
        String result;
        System.debug('Search ' + search);
        try{
            List<HDT_Generic_Record_Selection__mdt> configList = getterMethods.getConfigurationByName(search); 
            if(configList != null && configList.size()>0){
                result = JSON.serialize(configList);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return result;
    }
}