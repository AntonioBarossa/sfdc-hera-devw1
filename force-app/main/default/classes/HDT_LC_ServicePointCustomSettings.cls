public inherited sharing class HDT_LC_ServicePointCustomSettings {

    @AuraEnabled
    public static CS_SelezioneFornitura__c getCustomSettings(){
        return CS_SelezioneFornitura__c.getInstance();
    }
}
