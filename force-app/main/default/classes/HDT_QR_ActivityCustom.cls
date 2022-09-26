/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 04/06/2021
* @description Apex class HDT_QR_ActivityCustom
* @history Keltin Mesonjesi – 04/06/2021 – Created class
*/
public inherited sharing class HDT_QR_ActivityCustom {
    
    /**
    * @description getRecordByTypeAndStatusAndAccountAndServicePoint
    * @param type
    * @param status
    * @param accountId
    * @param servicePointCode
    * @return List<wrts_prcgvr__Activity__c>
    */
    public static List<wrts_prcgvr__Activity__c> getRecordByTypeAndStatusAndAccountAndServicePoint(String type, String status, String accountId, String servicePointCode) {
        return [
            SELECT
            Id,
            Name,
            wrts_prcgvr__Status__c,
            Account__c,
            ServicePointCode__c
            FROM wrts_prcgvr__Activity__c
            WHERE Type__c = :type
            AND wrts_prcgvr__Status__c = :status
            AND Account__c = :accountId
            AND ServicePointCode__c = :servicePointCode
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<wrts_prcgvr__Activity__c> getRecordByTypeAndStatusAndAccountAndServicePointNotStatus(String type, String status, String accountId, String servicePointCode) {
        return [
            SELECT
            Id,
            Name,
            wrts_prcgvr__Status__c,
            Account__c,
            ServicePointCode__c
            FROM wrts_prcgvr__Activity__c
            WHERE Type__c = :type
            AND wrts_prcgvr__Status__c != :status
            AND Account__c = :accountId
            AND ServicePointCode__c = :servicePointCode
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<wrts_prcgvr__Activity__c> getRecordById(String activityId) {
        return [
            SELECT
            Id,
            Account__c,
            wrts_prcgvr__Status__c,
            case__c,
            case__r.phase__c,
            Contact__c,
            Distributor__c,
            AppointmentDate__c
            FROM wrts_prcgvr__Activity__c
            WHERE Id= :activityId
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getRecordByIdAccise
    * @param activityId
    * @return List<wrts_prcgvr__Activity__c>
    */
    public static wrts_prcgvr__Activity__c getRecordByIdAccise(String activityId) {
        return [
            SELECT
            Id,
            Account__c,
            wrts_prcgvr__Status__c,
            order__c,
            order__r.ServicePoint__r.CommoditySector__c,
            order__r.FacilitationExcise__c,
            order__r.VATfacilitationFlag__c,
            Contact__c,
            Distributor__c,
            AppointmentDate__c,
            ageing__c, 
            isDenominazioneIncongruente__c,
            isIva10Module__c, 
            isIvaActivityCode__c,
            isAcciseContractualPower__c,
            isAcciseExclusionType__c,
            isAcciseCopyTechnicalRelation__c, 
            isAcciseExclusionModuleAccise__c,
            isIvaAnagrafici__c, 
            isIvaAtecoCode__c, 
            isIvaCopyDocument__c, 
            isIvaFirmLegalOwner__c, 
            isIvaMatricola__c, 
            isIvaSupplyAddress__c, 
            isManualAppoitment__c, 
            isSchoolCategory__c, 
            CraftsmenRegisterNumber__c,
            CheckActivityBox__c,
            RequiredOfficeActivity__c,
            CciaaData__c,
            IdentityDocument__c,
            AssociationStatute__c,
            Signature__c,
            AtecoCode__c,
            CciaaSelfCertModule__c,
            isAcciseModuleRequest__c,
            isAcciseSupply__c,
            PersonalData__c,
            NumberOfAttempt__c,
            isAccisePdrPod__c,
            CompletationDateDocument__c,
            createddate
            FROM wrts_prcgvr__Activity__c
            WHERE Id= :activityId
            WITH SECURITY_ENFORCED
        ];
    }

    public static wrts_prcgvr__Activity__c getRecordByIdValidation(String activityId) {
        return [
            SELECT
            Id,
            order__c,
            Account__c,
            Type__c,
            DiscardCount__c,
            isUserActivity__c
            FROM wrts_prcgvr__Activity__c
            WHERE Id= :activityId
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled
    public static wrts_prcgvr__Activity__c getRecordByIdS(String activityId) {
        return [
            SELECT
            Id,
            OwnerId,
            ManuallyReassigned__c,
            Queued__c,
            Account__c,
            wrts_prcgvr__Status__c,
            case__c,
            case__r.phase__c,
            recordtypeid,
            Contact__c,
            Distributor__c,
            AppointmentDate__c,
            CreatedById
            FROM wrts_prcgvr__Activity__c
            WHERE Id= :activityId
            WITH SECURITY_ENFORCED
            limit 1
        ];
    }

    public static List<wrts_prcgvr__Activity__c> getActivityKoPrecedenteClienteByIds(List<Id> activityIdList) {
        return [
            SELECT
            Id,
            Order__c,
            Order__r.ServicePoint__r.CommoditySector__c,
            Order__r.RecordType.DeveloperName,
            Order__r.Account.RecordType.DeveloperName,
            Order__r.ServicePoint__r.Account__r.FiscalCode__c,
            Order__r.ServicePoint__r.Account__r.VATNumber__c,
            Order__r.ServicePoint__c,
            Order__r.ServicePoint__r.AnnualConsumptionStandardM3__c,
            Order__r.ServicePoint__r.AnnualConsumption__c,
            Order__r.OrderNumber,
            Order__r.CreatedById,
            Order__r.Channel__c,
            Order__r.ChannelTransCode__c,
            Order__r.Account.CustomerCode__c,
            Order__r.SalesCompany__c,
            Order__r.Account.FiscalCode__c,
            Order__r.Account.VATNumber__c,
            Order__r.Account.CustomerMarking__c,
            Order__r.Account.Category__c,
            Order__r.Account.CustomerType__c,
            Order__r.Account.FirstName__c,
            Order__r.Account.LastName__c,
            Order__r.ServicePoint__r.SupplyStreetName__c,
            Order__r.ServicePoint__r.SupplyCity__c,
            Order__r.ServicePoint__r.SupplyProvince__c,
            Order__r.ServicePoint__r.SupplyPostalCode__c,
            Order__r.ProcessType__c,
            Order__r.Market__c,
            Order__r.Catalog__c,
            Order__r.ServicePoint__r.Account__r.CustomerCode__c
            FROM wrts_prcgvr__Activity__c
            WHERE Id IN :activityIdList 
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getRecordByCaseId
    * @param caseId
    * @return List<wrts_prcgvr__Activity__c>
    */
    public static List<wrts_prcgvr__Activity__c> getRecordByCaseId(String caseId) {
        return [
            SELECT

            Id,
            Approved__c,
            Name,
            wrts_prcgvr__status__c
            FROM wrts_prcgvr__Activity__c
            WHERE Case__c= :caseId
            WITH SECURITY_ENFORCED
        ];
    }
    @AuraEnabled
    public static List<wrts_prcgvr__Activity__c> getRecordByOrderIdAndType(String orderId,String type) {
        return [
            SELECT
            
            Id,
            Approved__c,
            Validation__c,
            Name,
            wrts_prcgvr__status__c
            FROM wrts_prcgvr__Activity__c
            WHERE Order__c= :orderId
            AND type__c = :type
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getRecordByCaseIdList
    * @param caseId
    * @return List<wrts_prcgvr__Activity__c>
    */
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

    /**
    * @description getRecordByOrderLine
    * @param quoteLine
    * @return List<wrts_prcgvr__Activity__c>
    */
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
    * @description getRecordByOwnerId
    * @param ownerIdList
    * @return List<wrts_prcgvr__Activity__c>
    */
    public static List<wrts_prcgvr__Activity__c> getRecordByOwnerId(List<String> ownerIdList) {
        return [
            SELECT
            Id,
            Approved__c,
            QuoteLine__c,
            case__c,
            owner.name,
            Name
            FROM wrts_prcgvr__Activity__c
            WHERE OwnerId IN :ownerIdList
            WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @author alessandro.picchiri@eng.it
     * @date 25/06/2021     
     * @description getActivityListCrediCheck
     * @param orderSetId
     * @return List<wrts_prcgvr__Activity__c>
    */
    public static List<wrts_prcgvr__Activity__c> getActivityListCrediCheck(Set<Id> orderSetId){
        List<wrts_prcgvr__Activity__c> actList = [SELECT Id,
                                                             RecordType.DeveloperName,
                                                             wrts_prcgvr__Status__c,
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
                                                                and wrts_prcgvr__IsClosed__c = false and Order__c IN :orderSetId WITH SECURITY_ENFORCED];

        return actList;}

        /**
         * @description getRejectedActivities
         * @param activityIds
         * @param recTypeId
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getRejectedActivities(Set<Id> activityIds, Id recTypeId) {
               return [
                   SELECT
                   Id,
                   ParentActivity__c,
                   DateTimeRef__c,Type__c
                   FROM wrts_prcgvr__Activity__c
                   WHERE ParentActivity__c IN :activityIds
                   AND RecordTypeId = :recTypeId 
                   AND Type__c= 'Scarto Comunicazione'
                   WITH SECURITY_ENFORCED
               ];
           }
        
        /**
         * @description getActivityByRecordId
         * @param activityId
         * @return List<wrts_prcgvr__Activity__c>
        */
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
                Order__r.ProcessType__c,
                Order__r.DateComfortCall__c,
                Order__r.ComfortCallDaysDue__c,
                Order__r.QualityCall__c,
                Order__r.QualityCallUnique__c,
                Order__r.ConfirmCustomerContract__c,
                Order__r.CancellationReason__c,
                Order__r.CommercialProduct__c,
                Order__r.VasSubtype__c
                FROM wrts_prcgvr__Activity__c
                WHERE Id = :activityId
                AND Order__r.VasSubtype__c != 'Analisi Consumi'
                WITH SECURITY_ENFORCED
            ];
        }
        
        /**
         * @description getRecordByParentIds
         * @param ids
         * @param recordTypeId
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getRecordByParentIds(Set<String> ids , Id recordTypeId){
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    Distributor__c,
                    AppointmentDate__c,
                    RecordTypeId
                    FROM wrts_prcgvr__Activity__c 
                    WHERE id IN: ids AND RecordTypeId =: recordTypeId 
                    WITH SECURITY_ENFORCED 
                ];
        }

        /**
         * @description getRecordScartoDiscordante
         * @param servicePoint
         * @param accountid
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getRecordScartoDiscordante(string servicePoint,string accountid){
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    order__c,
                    Distributor__c,
                    AppointmentDate__c,
                    RecordTypeId
                    FROM wrts_prcgvr__Activity__c
                    where 
                    RecordType.developername = 'HDT_RT_Scarto'
                    AND type__c = 'Gestione dati discordanti'
                    AND order__r.AccountId = :accountid
                    AND order__r.servicePoint__c = :servicePoint
                    AND order__r.Phase__c = 'Annullamento - Dati discordanti'
                    WITH SECURITY_ENFORCED 
                ];
        }
        public static List<wrts_prcgvr__Activity__c> getRecordScartoDiscordante(String orderId){
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    order__c,
                    Distributor__c,
                    AppointmentDate__c,
                    RecordTypeId
                    FROM wrts_prcgvr__Activity__c
                    WHERE 
                    RecordType.developername = 'HDT_RT_Scarto'
                    AND type__c = 'Gestione dati discordanti'
                    AND Order__c = :orderId
                    AND wrts_prcgvr__Status__c = 'Aperta'
                    WITH SECURITY_ENFORCED 
                ];
        }
        public List<wrts_prcgvr__Activity__c> getEsitoActivityDiscordante(String orderId){
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    order__c,
                    Distributor__c,
                    AppointmentDate__c,
                    ActivityOutcome__c,
                    RecordTypeId
                    FROM wrts_prcgvr__Activity__c
                    WHERE 
                    RecordType.developername = 'HDT_RT_Scarto'
                    AND type__c = 'Gestione dati discordanti'
                    AND Order__c = :orderId
                    AND wrts_prcgvr__Status__c = 'Chiusa'
                    WITH SECURITY_ENFORCED 
                    ORDER BY LastModifiedDate DESC
                ];
        }
        /**
         * @description getRecordByOrderAndQuality
         * @param orderid
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getRecordByOrderAndQuality(String orderid){
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    order__c,
                    RecordTypeId,
                    wrts_prcgvr__Status__c
                    FROM wrts_prcgvr__Activity__c
                    where 
                    RecordType.developername = 'HDT_RT_ComfortQualityCall'
                    AND order__C = :orderid
                    WITH SECURITY_ENFORCED 
            ];
        }

        /**
         * @description getRecordByOrderListAndQuality
         * @param orderList
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getRecordByOrderListAndQuality(List<Id> orderList){
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    order__c,
                    order__r.ParentOrder__c,
                    RecordTypeId,
                    wrts_prcgvr__Status__c
                    FROM wrts_prcgvr__Activity__c
                    where 
                    RecordType.developername = 'HDT_RT_ComfortQualityCall'
                    AND order__C IN :orderList
                    WITH SECURITY_ENFORCED 
            ];
        }

        /**
         * @description getRecordByOrderListAndQuality
         * @param orderList
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getRecordByOrderListAndQuality(Set<String> orderList){
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    order__c,
                    order__r.ParentOrder__c,
                    RecordTypeId,
                    wrts_prcgvr__Status__c
                    FROM wrts_prcgvr__Activity__c
                    where 
                    RecordType.developername = 'HDT_RT_ComfortQualityCall'
                    AND order__C IN :orderList
                    WITH SECURITY_ENFORCED 
            ];
        }

        /**
         * @description getRecordsForCancelQualityNoResult
         * @param idlist
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getRecordsForCancelQualityNoResult(List<Id> idlist){
            return [SELECT 
                    Id,
                    Account__c,
                    Account__r.ActiveMonitoring__c,
                    Contact__c,
                    order__c,
                    order__r.AgencyCode__c,
                    RecordTypeId,
                    RecordType.DeveloperName,
                    wrts_prcgvr__Status__c
                    FROM wrts_prcgvr__Activity__c
                    where Id in :idlist
                    WITH SECURITY_ENFORCED 
            ];
        }

    
        public static List<wrts_prcgvr__Activity__c> getActivityTelesellingOutbound(string ecid){
            return [select id,createddate from wrts_prcgvr__Activity__c where ecid__c = :ecid and Type__c = 'Chiamata outbound' and wrts_prcgvr__Status__c = 'Aperta' WITH SECURITY_ENFORCED order by createddate desc  ];
        }

        public static List<wrts_prcgvr__Activity__c> getActivityTelesellingOutboundByUser(){
            return [select id,createddate,Ecid__c from wrts_prcgvr__Activity__c where CreatedbyId =:userinfo.getUserId() AND Type__c = 'Chiamata outbound' and wrts_prcgvr__Status__c = 'Aperta' WITH SECURITY_ENFORCED order by createddate desc  ];
        }

        public static List<wrts_prcgvr__Activity__c> getRecordByEcid(String ecid){
            return [SELECT 
                    Id
                    FROM wrts_prcgvr__Activity__c
                    where ecid__c = :ecid
                    AND wrts_prcgvr__Status__c = 'Aperta'
                    WITH SECURITY_ENFORCED 
            ];
        }

        public static boolean isActivityNotClosed( String recordid ){

            Id myRecordId = (Id)recordid;

            switch on myRecordId.getSObjectType().getDescribe().getName() {
                when 'Case' {		
                    List<AggregateResult> activitiesNotClosed =  [SELECT COUNT(Id) 
                                                                    FROM wrts_prcgvr__Activity__c 
                                                                    WHERE wrts_prcgvr__Activity__c.Case__r.Id = :recordid
                                                                    AND wrts_prcgvr__IsClosed__c = false WITH SECURITY_ENFORCED];
                    return !((integer)activitiesNotClosed[0].get('expr0') > 0);
                }	
                when 'Order' {
                    List<AggregateResult> activitiesNotClosed =  [SELECT COUNT(Id) 
                                                                    FROM wrts_prcgvr__Activity__c 
                                                                    WHERE wrts_prcgvr__Activity__c.Order__r.Id = :recordid
                                                                    AND wrts_prcgvr__IsClosed__c = false WITH SECURITY_ENFORCED];
                   return !((integer)activitiesNotClosed[0].get('expr0') > 0);
                }
                when else{
                    return true;
                }
            }

        }
    
    public static Map<String, wrts_prcgvr__Activity__c> getQualCallByParentOrder(Set<String> parentOrderSet){

        Map<String, wrts_prcgvr__Activity__c> parentActMap = new Map<String, wrts_prcgvr__Activity__c>();

        List<wrts_prcgvr__Activity__c> actList = [SELECT Id, Order__c, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c 
            WHERE Order__c = :parentOrderSet AND Type__c = 'Quality Call' AND wrts_prcgvr__IsClosed__c = false AND wrts_prcgvr__Status__c = 'Aperta' WITH SECURITY_ENFORCED];

        for(wrts_prcgvr__Activity__c act : actList){
            parentActMap.put(act.Order__c, act);
        }
        return parentActMap;
    }

    /**
         * @description getRecordByOrderListAndQuality
         * @param orderList
         * @return List<wrts_prcgvr__Activity__c>
        */
        public static List<wrts_prcgvr__Activity__c> getActivityCreatedByQualityBatch(List<String> orderList){
            Set<String> activityTypes = new Set<String>{HDT_UTL_ActivityCustom.ANNULLAMENTO_SIEBEL,HDT_UTL_ActivityCustom.CONTRATTO_NON_RICHIESTO};
            return [SELECT 
                    Id,
                    Account__c,
                    Contact__c,
                    order__c,
                    order__r.ParentOrder__c,
                    RecordTypeId,
                    wrts_prcgvr__Status__c,
                    wrts_prcgvr__IsClosed__c,
                    RecordType.DeveloperName,
                    Type__c
                    FROM wrts_prcgvr__Activity__c
                    where 
                    (RecordType.developername = 'HDT_RT_ComfortQualityCall'
                    OR Type__c IN :activityTypes)
                    AND order__C IN :orderList
                    WITH SECURITY_ENFORCED 
            ];
        }
}