public with sharing class HDT_QR_AmsAdministration {

    public List<Order> getOrderToSeq(){
        return [SELECT Id,
        Status,
        Phase__c, 
        DiscardReason__c, 
        SapContractCode__c,
        Account.CustomerMarking__c,
        Account.CustomerCode__c,
        OrderReference__r.Phase__c,
        (Select Id, Type__c, wrts_prcgvr__Status__c FROM Activities_Custom__r WHERE wrts_prcgvr__Status__c = 'Aperta' AND Type__c = 'Scarto transitorio')
        FROM Order 
        WHERE  ProcessType__c ='VAS'
        AND SapContractCode__c=''
        AND isTransition__c = true
        AND Phase__c   in ('Esportazione vs Siebel','Caricamento Siebel KO')
        AND OrderReference__c !=''
        AND OrderReference__r.Phase__c not in ('Completata','Annullato')
        WITH SECURITY_ENFORCED
        ];
    }

    public List<Order> getOrderToDeseq(){
        return [SELECT Id,
        OrderNumber,
        Phase__c,
        (select id from ServiceRequests__r),
        Status
        FROM Order 
        WHERE  CommercialProduct__c!='Analisi Consumi'
        AND VasSubtype__c!='Analisi Consumi'
        AND Phase__c ='Sequenzializzato'
        AND ProcessType__c ='VAS'
        AND OrderReference__r.Phase__c in ('Completata')
        AND isTransition__c= true
        WITH SECURITY_ENFORCED
        ORDER BY OrderReference__r.CreatedDate DESC
        ];
    }

    public List<HDT_AmsAdministration__mdt> fetchConfigs()
    {
        return [SELECT ClassName__c, Method__c, MasterLabel FROM HDT_AmsAdministration__mdt WHERE IsActive__c = true WITH SECURITY_ENFORCED];
    }

    public List<AmsAdministration__c> getCurrentDateRecords(){
        return [SELECT Id, Process__c, Status__c FROM AmsAdministration__c WHERE CreatedDate = TODAY WITH SECURITY_ENFORCED];
    }

    public List<AmsAdministration__c> getTodayPendingOperations(){
        return [SELECT Id FROM AmsAdministration__c WHERE CreatedDate = TODAY AND Status__c = 'PENDING' WITH SECURITY_ENFORCED];
    }

}