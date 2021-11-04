@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_LC_BillingProfileSelection {
    private static HDT_QR_BillingProfileSelection getterMethods = new HDT_QR_BillingProfileSelection();

    @AuraEnabled(cacheable = true)
    public static String getConfiguration(String search){
        String result;
        System.debug(LoggingLevel.DEBUG, 'Search ' + search);
        try{
            List<HDT_Generic_Record_Selection__mdt> configList = getterMethods.getConfigurationByName(search); 
            if(configList != null && configList.size()>0){
                result = JSON.serialize(configList);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'getConfiguration - Exception TypeName: ' + e.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'getConfiguration - Exception Message: ' + e.getMessage());
            System.debug(LoggingLevel.DEBUG, 'getConfiguration - Exception StackTraceString: ' + e.getStackTraceString());
        }
        return result;
    }
}