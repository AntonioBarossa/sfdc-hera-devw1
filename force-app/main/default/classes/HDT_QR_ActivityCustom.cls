public inherited sharing class HDT_QR_ActivityCustom {
    public static List<wrts_prcgvr__Activity__c> getRecordByTypeAndStatusAndAccountAndServicePoint(String type, String status, String accountId, String servicePointCode) {
        return [
            SELECT
            Id,
            Name,
            Status__c,
            Account__c,
            ServicePointCode__c
            FROM wrts_prcgvr__Activity__c
            WHERE Type__c = :type
            AND Status__c = :status
            AND Account__c = :accountId
            AND ServicePointCode__c = :servicePointCode
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<wrts_prcgvr__Activity__c> getRecordByCaseId(String caseId) {
        return [
            SELECT
            
            Id,
            Approved__c,
            Name
            FROM wrts_prcgvr__Activity__c
            WHERE Case__c= :caseId
            WITH SECURITY_ENFORCED
        ];
    }
    public static List<wrts_prcgvr__Activity__c> getRecordByCaseIdList(List<String> caseId) {
        return [
            SELECT
            Id,
            Approved__c,
            case__c,
            owner.name,
            Name
            FROM wrts_prcgvr__Activity__c
            WHERE Case__c IN :caseId
            WITH SECURITY_ENFORCED
        ];
    }
    public static List<wrts_prcgvr__Activity__c> getRecordByOrderLine(List<String> quoteLine) {
        return [
            SELECT
            Id,
            Approved__c,
            QuoteLine__c,
            case__c,
            owner.name,
            Name
            FROM wrts_prcgvr__Activity__c
            WHERE QuoteLine__c IN :quoteLine
            WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @author alessandro.picchiri@eng.it
     * @date 25/06/2021     
    */
    public static List<wrts_prcgvr__Activity__c> getActivityListCrediCheck(Set<Id> orderSetId){
        List<wrts_prcgvr__Activity__c> actList = [SELECT Id,
                                                             RecordType.DeveloperName,
                                                             Status__c,
                                                             CreditCheckResults__c,
                                                             Order__c,
                                                             Order__r.OrderNumber,
                                                             Order__r.CreatedById,
                                                             Order__r.Channel__c,  
                                                             Order__r.ProcessType__c,
                                                             Order__r.Market__c,
                                                             Order__r.Catalog__c, 
                                                             Order__r.SalesCompany__c,                                                             
                                                             Order__r.ServicePoint__r.CommoditySector__c,
                                                             Order__r.ServicePoint__r.SupplyStreetName__c,
                                                             Order__r.ServicePoint__r.SupplyCity__c,
                                                             Order__r.ServicePoint__r.SupplyProvince__c,
                                                             Order__r.ServicePoint__r.SupplyPostalCode__c,
                                                             Order__r.ServicePoint__r.Account__r.CustomerCode__c,
                                                             Order__r.ServicePoint__r.Account__r.VATNumber__c,
                                                             Order__r.ServicePoint__r.AnnualConsumptionStandardM3__c,
                                                             Order__r.RecordType.DeveloperName,
                                                             Order__r.Account.CustomerCode__c,
                                                             Order__r.Account.FiscalCode__c,
                                                             Order__r.Account.VATNumber__c,
                                                             Order__r.Account.CustomerMarking__c,
                                                             Order__r.Account.Category__c,
                                                             Order__r.Account.CustomerType__c,
                                                             Order__r.Account.RecordType.DeveloperName                                                             
                                                       FROM wrts_prcgvr__Activity__c 
                                                       WHERE  (RecordType.DeveloperName = 'HDT_RT_CreditCheckKO' or RecordType.DeveloperName = 'HDT_RT_KoPrecedeteCliente') 
                                                                and Status__c = 'Creata' and Order__c IN :orderSetId];

        return actList;
    }

    public static List<wrts_prcgvr__Activity__c> getActivityByRecordId(String activityId){
        return [
            SELECT Id,
            Type__c,
            Order__c,
            Order__r.AccountId,
            Order__r.Account.Name,
            Order__r.Recordtypeid,
            Order__r.Recordtype.Name,
            Order__r.Recordtype.DeveloperName,
            Order__r.Status,
            Order__r.Phase__c,
            Order__r.OrderNumber,
            Order__r.ProcessType__c
            FROM wrts_prcgvr__Activity__c
            WHERE Id = :activityId
            WITH SECURITY_ENFORCED
        ];
    }
}
