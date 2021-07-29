/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 10/03/2021
* @description HDT_QR_Case– Contains queries for Case
* @history Fatjola Memishaj – 10/03/2021 – Created class
*/

public inherited sharing class HDT_QR_Case {

    public List<Case> getRecordByPracticeNumber(String caseNumber){
        return [SELECT Order__r.Id,Asset.Id,Subscription__r.Id FROM Case
        WHERE CaseNumber = :caseNumber WITH SECURITY_ENFORCED LIMIT 1];
    }
    
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

    public List<Case> getRecordCreatedYesterdayDifferentBy(String cluster){
        return [Select id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c from Case where cluster__c != : cluster AND createddate = Yesterday ];
    }

    public List<Case> getRecordCreatedLastWeekEqualsBy(String cluster){
        return [Select id,origin,createddate,Createdby.Name,CreatorGroup__c,station__c,phase__c,type,Cluster__c,CommodityFormula__c,Casenumber,Account.Segment__c,Account.CategoryCode__c,Account.Category__c,Account.Name,account.RowIdSiebel__c,account.SAPIntegrationID__c from Case where cluster__c = : cluster AND CreatedDate = LAST_N_DAYS:7];
    }


    /*** FIne Sviluppo per Campagne */

}