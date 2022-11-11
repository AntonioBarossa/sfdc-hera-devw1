/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 10/03/2021
* @description HDT_QR_Case– Contains queries for Case
* @history Fatjola Memishaj – 10/03/2021 – Created class
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_QR_Case {

    public List<Case> getRecordByPracticeNumber(String caseNumber){
        return [SELECT Order__r.Id,Asset.Id,Subscription__r.Id FROM Case
        WHERE CaseNumber = :caseNumber WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    
    @SuppressWarnings('PMD.FormalParameterNamingConventions')
    public Case getRecordById(String Id) {
        return [
            SELECT 
            Id,
            Status,
            Subject,
            Subprocess__c,
            AccountId,
            CaseNumber,
            HerokuPracticeCode__c,
            /*** Sviluppo Gest Appuntamento */
            Contact.FiscalCode__c,
            Contact.VATNumber__c,
            ServicePoint__r.distributor__r.name,
            ServicePoint__r.distributor__c,
            ServicePoint__r.CommoditySector__c, //@Elfrida Kora,06/10/2021
            ServicePoint__r.Account__c, //@Elfrida Kora,06/10/2021
            /*** FINE */
            ContactId,
            ServicePoint__c,
            Contract__c,
            ContractCode__c,
            CommodityFormula__c,
            PODPDRFormula__c,
            Phase__c,
            Type,
            Distributor__r.Name,
            Commodity__c,
            SalesCompanyCode__c,
            CausalCode__c,
            Distributor__r.Code__c,
            RecordType.DeveloperName
            FROM Case
            where Id = :Id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
    /*******
     *  Cambio uso TEcnico
     */
    
    @SuppressWarnings('PMD.FormalParameterNamingConventions')
    public Case getRecordByIdCambioUso(String Id) {
        return [
            SELECT 
            Id,
            Status,
            Subject,
            Subprocess__c,
            AccountId,
            CaseNumber,
            ServicePoint__r.Distributor__r.Code__c,
            HerokuPracticeCode__c,
            /*** Sviluppo Gest Appuntamento */
            ServicePoint__r.distributor__r.name,
            ServicePoint__r.distributor__c,
            /*** FINE */
            ContactId,
            ServicePoint__c,
            Contract__c,
            ContractCode__c,
            CommodityFormula__c,
            PODPDRFormula__c,
            Phase__c,
            Type,
            RecordType.DeveloperName
            FROM Case
            where Id = :Id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public List<Case> getChageNonRegMeterByOrder(String orderId){

        return [SELECT Id
        FROM Case
        WHERE Type = 'Cambio Contatore Non Registrato'
        AND Phase__c = 'Completata'
        AND VulturePracticeReference__c = :orderId
        WITH SECURITY_ENFORCED];
        
    }

    public Case getParentCaseById(String caseId){

        if (caseId == null) {
            return null;
        }

        return [SELECT Id,
        Type,
        Phase__c,
        DistributorName__c
        FROM Case
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }
    
    public List<Case> getCasesByCaseNumbers(list<String> caseNumbers){

        if (caseNumbers == null || caseNumbers.isEmpty()) {
            return null;
        }
        return [SELECT Id,Type,Phase__c,DistributorName__c,AccountId FROM Case
                                                           WHERE CaseNumber IN :caseNumbers WITH SECURITY_ENFORCED];
    }

    @SuppressWarnings('PMD.FormalParameterNamingConventions')
    public List<Case> getRecordsById(List<String> Ids, String fields) {
        String query = 'SELECT '+ String.escapeSingleQuotes(fields) + ' FROM Case where Id IN :Ids';
        List<Case> cases = Database.query(query); 

        return cases;
    }

    /*****Sviluppo per Campagne */

    public List<Case> getRecordCreatedYesterdayDifferentBy(String cluster){
        return [Select id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,MacroTopic__c,SalesCompany__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c from Case where cluster__c != : cluster AND createddate = Yesterday WITH SECURITY_ENFORCED];
    }

    public List<Case> getRecordCreatedInRequestedDateDifferentBy(String cluster, Datetime startDt, Datetime endDt){
        return [Select id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,MacroTopic__c,SalesCompany__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c from Case where cluster__c != : cluster AND CreatedDate >=:startDt and CreatedDate <: endDt WITH SECURITY_ENFORCED];
    }

    public List<Case> getRecordCreatedLastWeekEqualsBy(String cluster){
        return [Select Case.MotivatedResponseSendMode__c, Case.ParentId,Case.CorrectionRight__c,ServicePoint__r.SupplyCity__c,Case.ServicePoint__c,Case.IndemnityConfirmed__c,Case.CustomerRequestNumberDay__c,Case.Subprocess__c,Case.IsReiteration__c,Case.Status,Account.CustomerCode__c,Case.SupplyType__c,Case.ClosedDate,Case.CustomerRequestDate__c,Case.CompanyOwner__c,id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c, SupplyCityCode__c, ServicePoint__r.SupplyProvince__c from Case where cluster__c = : cluster AND CreatedDate = LAST_N_DAYS:7 WITH SECURITY_ENFORCED]; // aggiunti campi alla query
    }

    public List<Case> getRecordCreatedLastDayEqualsBy(String cluster){
        return [Select Case.MotivatedResponseSendMode__c, Case.ParentId,Case.CorrectionRight__c,ServicePoint__r.SupplyCity__c,Case.ServicePoint__c,Case.IndemnityConfirmed__c,Case.CustomerRequestNumberDay__c,Case.Subprocess__c,Case.IsReiteration__c,Case.Status,Account.CustomerCode__c,Case.SupplyType__c,Case.ClosedDate,Case.CustomerRequestDate__c,Case.CompanyOwner__c,id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c, SupplyCityCode__c, ServicePoint__r.SupplyProvince__c from Case where cluster__c = : cluster AND CreatedDate = Yesterday WITH SECURITY_ENFORCED]; // aggiunti campi alla query
    }

    public List<Case> getRecordCreatedInRequestedDate(String cluster, Datetime startDt, Datetime endDt){
        return [Select Case.MotivatedResponseSendMode__c, Case.ParentId,Case.CorrectionRight__c,ServicePoint__r.SupplyCity__c,Case.ServicePoint__c,Case.IndemnityConfirmed__c,Case.CustomerRequestNumberDay__c,Case.Subprocess__c,Case.IsReiteration__c,Case.Status,Account.CustomerCode__c,Case.SupplyType__c,Case.ClosedDate,Case.CustomerRequestDate__c,Case.CompanyOwner__c,id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c, SupplyCityCode__c, ServicePoint__r.SupplyProvince__c from Case where cluster__c = : cluster AND CreatedDate >=: startDt AND CreatedDate <:endDt WITH SECURITY_ENFORCED];
    }

    public List<Case> getCaseModificaContratti(String podPdr){
        return [Select Phase__c, CaseNumber from Case where ServicePointCode__c=:podPdr AND RecordType.DeveloperName='HDT_RT_GenericheAttivazioni' AND ServicePoint__c='' AND Type LIKE 'Modifica Contr Preattivazione%'  WITH SECURITY_ENFORCED ORDER BY Phase__c DESC ]; // aggiunti campi alla query
    }

    /*** FIne Sviluppo per Campagne */

    public List<Case> getChildCase(String parentId){
        List<Case> childCases = new List<Case>();
        try{
            childCases = [SELECT Id,
            CaseNumber,
            Status,
            Phase__c
            FROM Case
            WHERE ParentId = :parentId
            AND RecordType.DeveloperName = 'HDT_RT_RichiestaParere'
            WITH SECURITY_ENFORCED];
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'ChildCaseCancellation: ' + e.getMessage() + '. At line: ' + e.getLineNumber());
        }
        return childCases;
    }

    public List<wrts_prcgvr__Activity__c> getCaseActivities(List<String> caseIds){

        List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
        try{
            activities = [SELECT Id,
            OwnedByUser__c,
            OwnerId,
            wrts_prcgvr__Status__c,
            wrts_prcgvr__ActivityTemplate__r.Name
            FROM wrts_prcgvr__Activity__c
            WHERE (wrts_prcgvr__Status__c != 'Chiusa' AND wrts_prcgvr__Status__c != 'Annullata')
            AND wrts_prcgvr__IsClosed__c = false
            AND Case__c IN :caseIds
            WITH SECURITY_ENFORCED
            ];
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'ChildCaseCancellation: ' + e.getMessage() + '. At line: ' + e.getLineNumber());
        }
        return activities;
    }

    public List<Case> getServicePointCaseWinBack(String servicePointId){
        return [
        SELECT 
        Id,
        Phase__c,
        DistributorName__c
        FROM Case
        WHERE ServicePoint__c = :servicePointId
        AND Type = 'Switch Out SII'
        AND Status = 'In Lavorazione'
        WITH SECURITY_ENFORCED
        ];
    }

    public List<Case> getServicePointCaseWinBack(String servicePointId, String servicePointCode){
        return [
        SELECT 
        Id,
        Phase__c,
        DistributorName__c
        FROM Case
        WHERE (ServicePoint__c = :servicePointId OR ServicePointCode__c = :servicePointCode)
        AND (Type = 'Switch Out SII' OR Type = 'Switch Out dal SII')
        AND Status = 'In Lavorazione'
        WITH SECURITY_ENFORCED
        ];
    }

    public Case getNonReqContrCase(String relatedCase){
        Case nonReqContr = new Case();
        try{
            nonReqContr = [SELECT Id,
            Phase__c,
            Type
            FROM Case
            WHERE Type = 'Contratto Non Richiesto'
            AND RelatedCase__c = :relatedCase
            WITH SECURITY_ENFORCED
            LIMIT 1];
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Non Required Contract: ' + e.getMessage() + '. At line: ' + e.getLineNumber());
        }
        return nonReqContr;
    }

    public Case getNonReqContrOrder(String relatedOrder){
        Case nonReqContr = new Case();
        try{
            nonReqContr = [SELECT Id,
            Phase__c,
            Type
            FROM Case
            WHERE Type = 'Contratto Non Richiesto'
            AND Order__c = :relatedOrder
            WITH SECURITY_ENFORCED
            LIMIT 1];
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Non Required Contract: ' + e.getMessage() + '. At line: ' + e.getLineNumber());
        }
        return nonReqContr;
    }
    
    public Case getCaseRelated(String relatedOrder){
        Case nonReqContr = [SELECT Id,
            Phase__c,
            Type
            FROM Case
            where
            Order__c = :relatedOrder
            WITH SECURITY_ENFORCED
            LIMIT 1];
        
        return nonReqContr;
    }

    public List<Case> getChildCasesReclamo(String note, String recordId)
    {
        List<String> childIds = note.split(';');
        List<Case> childCases = new List<Case>();
        try
        {
            childCases = [SELECT Id, CorrectionRight__c, ServicePoint__c,FirstLevelComplaintClassification__c,SecondLevelComplaintClassification__c, CorrectionDocumentEmissionDay__c,IndemnityConfirmed__c, Phase__c, Status FROM Case WHERE ParentId = :recordId AND Id IN :childIds WITH SECURITY_ENFORCED];
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.DEBUG, 'Errore: ' + e.getMessage() + '. Alla riga: ' + e.getLineNumber());
        }
        return childCases;
    }
    /**@frpanico 22/10/2021
     * modified input parameter from String type to Set<String> types
     * To query records with different types
     */
    public List<Case> getCaseByAccountid(String accountid, Set<String> types)
    {
        return [SELECT Id, CorrectionRight__c, CorrectionDocumentEmissionDay__c,IndemnityConfirmed__c, Phase__c, Status FROM Case WHERE AccountId = :accountid AND type IN :types AND isClosed = false WITH SECURITY_ENFORCED];
    }

}