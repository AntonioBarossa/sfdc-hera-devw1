/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 10/03/2021
* @description HDT_QR_Case– Contains queries for Case
* @history Fatjola Memishaj – 10/03/2021 – Created class
*/

public inherited sharing class HDT_QR_Case {
    
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
            ContactId,
            ServicePoint__c,
            Contract__c,
            ContractCode__c,
            CommodityFormula__c,
            PODPDRFormula__c
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

        return [SELECT Id,
        Type,
        Phase__c,
        DistributorName__c
        FROM Case
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }

    public List<Case> getRecordsById(List<String> Ids, String fields) {
        String query = 'SELECT '+ fields +
                ' From Case where id IN :Ids';
        List<Case> cases = Database.query(query);

        return cases;
    }

    /*****Sviluppo per Campagne */
    //Everis: Aggiunto WITH SECURITY_ENFORCED alla query altrimenti vengo bloccato da Clayton.
    public List<Case> getRecordCreatedYesterdayDifferentBy(String cluster){
        return [Select id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c from Case where cluster__c != : cluster AND createddate = Yesterday WITH SECURITY_ENFORCED];
    }

    public List<Case> getRecordCreatedLastWeekEqualsBy(String cluster){
        return [Select id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c from Case where cluster__c = : cluster AND CreatedDate = LAST_N_DAYS:7 WITH SECURITY_ENFORCED];
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
            WITH SECURITY_ENFORCED];
        }catch(Exception e){
            System.debug('ChildCaseCancellation: ' + e.getMessage() + '. At line: ' + e.getLineNumber());
        }
        return childCases;
    }

    public List<wrts_prcgvr__Activity__c> getCaseActivities(List<String> caseIds){

        List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
        try{
            activities = [SELECT Id,
            wrts_prcgvr__Status__c,
            Status__c
            FROM wrts_prcgvr__Activity__c
            WHERE wrts_prcgvr__Status__c = 'Not Started'
            AND Case__c IN :caseIds
            WITH SECURITY_ENFORCED
            ];
        }catch(Exception e){
            System.debug('ChildCaseCancellation: ' + e.getMessage() + '. At line: ' + e.getLineNumber());
        }
        return activities;
    }

}