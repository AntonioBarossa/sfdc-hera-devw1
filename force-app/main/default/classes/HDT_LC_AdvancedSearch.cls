public with sharing class HDT_LC_AdvancedSearch {

    private static List<ServicePoint__c> servicePoints;

    /*
	 * Retrieve data from ServicePoint Object By ServiceCode
	 */
    @AuraEnabled(cacheable = true)
    public static List<ServicePoint__c> getServicePointsByName(String code) {
        CS_SelezioneFornitura__c customSetting = getCustomSetting();
        String stringCode = '%' + code.trim() + '%';
        String query = 'SELECT '+ customSetting.OutputServicePoint__c + ' FROM ServicePoint__c WHERE ServicePointCode__c LIKE :stringCode ';
        List<ServicePoint__c> serivePoints =  Database.query(query);
        if(serivePoints.size() > (customSetting.Max_Record__c).intValue()){
            throw new AuraHandledException('Number of record reached Maximum exceeded');
        }
        return serivePoints;
    }

    /*
	 * Getting Custom Settimg  'CS_SelezioneFornitura'
	 */
    static CS_SelezioneFornitura__c getCustomSetting() {
        return [SELECT Max_Record__c,OutputServicePoint__c FROM CS_SelezioneFornitura__c][0];
    }
}
