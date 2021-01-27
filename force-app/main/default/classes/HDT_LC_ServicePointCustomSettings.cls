/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Apex controller that returns service point custom settings, called from hdtTargetObjectCreateForm.js
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/
public inherited sharing class HDT_LC_ServicePointCustomSettings {

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get ServicePoint__c custom settings
     * @return CS_SelezioneFornitura__c
     */
    @AuraEnabled
    public static CS_SelezioneFornitura__c getCustomSettings(){
        return CS_SelezioneFornitura__c.getInstance();
    }
}
