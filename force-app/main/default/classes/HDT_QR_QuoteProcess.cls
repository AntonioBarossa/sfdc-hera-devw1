/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 16/12/2020
* @description Query class for SBQQ__QuoteProcess__c
* @history Keltin Mesonjesi – 16/12/2020 – Created class
*/
public inherited sharing class HDT_QR_QuoteProcess {
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get records for SBQQ_QuoteLineGroup association
     * @return List<SBQQ__QuoteProcess__c>
     */
    public List<SBQQ__QuoteProcess__c> getProcessForGroupAssoc(){
        return [
            SELECT 
            SBQQ__Default__c, 
            SBQQ__GuidedOnly__c, 
            SBQQ__ProductAutoSelected__c, 
            SBQQ__ProductConfigurationInitializer__c, 
            SBQQ__ProductSearchExecutor__c, 
            SBQQ__SortOrder__c,
            Name
            FROM 
            SBQQ__QuoteProcess__c 
            WHERE Name = 'Vendita Guidata Offerte'
            WITH SECURITY_ENFORCED
            ];
    }

}
