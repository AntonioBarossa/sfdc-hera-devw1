public inherited sharing class HDT_QR_HerokuPostSalesManager {

    public wrts_prcgvr__CalloutTemplate__c getCalloutTemplateByCode(String code){

        wrts_prcgvr__CalloutTemplate__c calloutTemplate = new wrts_prcgvr__CalloutTemplate__c();

        try{

            calloutTemplate = [SELECT 
            Id,
            wrts_prcgvr__ConfigurationFile__c, 
            wrts_prcgvr__Code__c, 
            wrts_prcgvr__IncludeNullFields__c, 
            wrts_prcgvr__ObjectType__c, 
            wrts_prcgvr__Structure__c 
            FROM wrts_prcgvr__CalloutTemplate__c 
            WHERE wrts_prcgvr__Code__c = :code
            WITH SECURITY_ENFORCED
            LIMIT 1];

        } catch(Exception e){

            calloutTemplate = null;

        }

        return calloutTemplate;

    }

    public Case getCaseRecord(String recordId){
        Case recordCase = new Case();
        try {
            if(recordId instanceOf Id){
                recordCase = [SELECT Id,TotalResidue__c,RefundMethod__c,Type,Cluster__c, AccountCode__c,ContractAccountCode__c,CausalCode__c,ContractCode__c, QuotationType__c,ServicePoint__c, RecordTypeId, AccountId, ContactId, ParentId, Parent.CaseNumber, Description, Phase__c,CaseNumber,HerokuPracticeCode__c,CancellationHerokuPracticeCode__c,CalculationBlock__c,CancellationNote__c, CommodityFormula__c, PODPDRFormula__c, Status,DistributorNote__c,Note__c,DocumentNumber__c,BillNumber__c,IbanIsForeign__c, BillingProfile__c, Subprocess__c FROM Case WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
            }else if(recordId.containsIgnoreCase('1-')){
                String likeSiebelNumber = '%' + recordId + '%';
                recordCase = [SELECT Id,TotalResidue__c,RefundMethod__c,Type,Cluster__c, AccountCode__c,CausalCode__c,ContractAccountCode__c,ContractCode__c, QuotationType__c,ServicePoint__c, RecordTypeId, AccountId, ContactId, ParentId, Parent.CaseNumber, Description, Phase__c,CaseNumber,HerokuPracticeCode__c,CancellationHerokuPracticeCode__c, CalculationBlock__c,CancellationNote__c, CommodityFormula__c, PODPDRFormula__c, Status,DistributorNote__c,Note__c,DocumentNumber__c,BillNumber__c,IbanIsForeign__c, BillingProfile__c, Subprocess__c FROM Case WHERE GlobalMigrationKey__c LIKE :likeSiebelNumber WITH SECURITY_ENFORCED LIMIT 1];
            }else {
                recordCase = [SELECT Id,BillingProfile__c,TotalResidue__c,RefundMethod__c,Type,Cluster__c, AccountCode__c,CausalCode__c,ContractAccountCode__c,ContractCode__c, QuotationType__c,ServicePoint__c, RecordTypeId, AccountId, ContactId, ParentId, Parent.CaseNumber, Description, Phase__c,CaseNumber,HerokuPracticeCode__c,CancellationHerokuPracticeCode__c, CalculationBlock__c,CancellationNote__c, CommodityFormula__c, PODPDRFormula__c, Status,DistributorNote__c,Note__c,DocumentNumber__c,BillNumber__c,IbanIsForeign__c, Subprocess__c FROM Case WHERE CaseNumber =:recordId WITH SECURITY_ENFORCED LIMIT 1];
            }
            
        } catch (DmlException ex) {
            throw ex;
        }
        return recordCase;
    }

    public Account getAccount(String accountCode){
        return [SELECT Id, FiscalCode__c,VATNumber__c FROM Account WHERE CustomerCode__c=:accountCode WITH SECURITY_ENFORCED LIMIT 1];
    }

    public Account getAccountFromSp(String pod){
        ServicePoint__c sp = [SELECT Account__r.Id, Account__r.FiscalCode__c,Account__r.VATNumber__c FROM ServicePoint__c WHERE ServicePointCode__c =:pod WITH SECURITY_ENFORCED LIMIT 1];
        Account account = sp.Account__r;
        return account;
    }
    public Contact getContact(String accountId){
        AccountContactRelation rel = [SELECT ContactId,Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.Id,Contact.CompanyOwner__c FROM AccountContactRelation WHERE AccountId =:accountId AND Roles = 'Titolare' WITH SECURITY_ENFORCED LIMIT 1];
        Contact contact = rel.Contact;
        return contact;
    }

    public ServicePoint__c getServicePoint(String code){
        return [SELECT Id, CommoditySector__c FROM ServicePoint__c WHERE ServicePointCode__c=:code WITH SECURITY_ENFORCED LIMIT 1];
    }
    /* è necessario far creare la pratica di richiesta passiva per contratto cessato
    * In modo che si abbia traccia che la cessazione e' gia' avvenuta
    * tramite errore sulla pratica stessa
    */
    public Contract getContract(String servicePointId){
        return [SELECT Id,BillingProfile__c,SAPContractCode__c, EndDate FROM Contract WHERE ServicePoint__c=:servicePointId AND Status IN ('Attivo','Cessato') WITH SECURITY_ENFORCED ORDER BY Status ASC  LIMIT 1 ];
    }

    public HDT_CausalCodeCalculation__mdt getCausalCode(String cluster, String process, String commodity){
        return [SELECT Id, 
        CausalCode__c,
        OperationCode__c
        FROM  HDT_CausalCodeCalculation__mdt
        WHERE Cluster__c = :cluster
        AND Process__c = :process
        AND Commodity__c = :commodity
        WITH SECURITY_ENFORCED
        LIMIT 1];
    }

    public Case getRelatedCase(String recordId){
        return [SELECT Id,
        Type,
        Phase__c,
        CreatedDate,
        ParentId
        FROM Case
        WHERE Type = 'Sospensione Fornitura'
        AND ParentId = :recordId
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
        LIMIT 1];
    }

    public wrts_prcgvr__AsyncJob__c getAsyncJobByJobItem(String recordId){

        List<wrts_prcgvr__AsyncJob__c> asyncJobRec = new List<wrts_prcgvr__AsyncJob__c>();

        try{
            asyncJobRec = [ SELECT Id, wrts_prcgvr__Details__c, wrts_prcgvr__Status__c
                            FROM wrts_prcgvr__AsyncJob__c
                            WHERE wrts_prcgvr__JobItem__c = :recordId
                            AND (wrts_prcgvr__Status__c = 'Chiusa'
                            OR wrts_prcgvr__Status__c = 'Queued')
                            WITH SECURITY_ENFORCED];
        }catch(Exception e){
            asyncJobRec = null;
        }

        return asyncJobRec[0];

    }

}