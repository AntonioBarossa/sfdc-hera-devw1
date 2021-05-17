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

            System.debug(e.getMessage());

        }

        return calloutTemplate;

    }

    public Case getCaseRecord(String recordId){
        Case recordCase = new Case();
        try {
            recordCase = [SELECT Id, Description, Phase__c,CaseNumber FROM Case WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
        } catch (DmlException ex) {
            throw ex;
        }
        return recordCase;
    }

    public Account getAccount(String accountCode){
        return [SELECT Id, FiscalCode__c,VATNumber__c FROM Account WHERE CustomerCode__c=:accountCode WITH SECURITY_ENFORCED LIMIT 1];
    }

    public Account getAccountFromSP(String pod){
        ServicePoint__c sp = [SELECT Account__r.Id, Account__r.FiscalCode__c,Account__r.VATNumber__c FROM ServicePoint__c WHERE ServicePointCode__c =:pod WITH SECURITY_ENFORCED LIMIT 1];
        Account account = sp.Account__r;
        return account;
    }
    public Contact getContact(String accountId){
        AccountContactRelation rel = [SELECT ContactId,Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.Id FROM AccountContactRelation WHERE AccountId =:accountId AND Roles = 'Titolare' WITH SECURITY_ENFORCED LIMIT 1];
        Contact contact = rel.Contact;
        return contact;
    }

    public ServicePoint__c getServicePoint(String code){
        return [SELECT Id FROM ServicePoint__c WHERE ServicePointCode__c=:code WITH SECURITY_ENFORCED LIMIT 1];
    }

    public Contract getContract(String servicePointId){
        return [SELECT Id,BillingProfile__c, EndDate FROM Contract WHERE ServicePoint__c=:servicePointId AND Status ='Attivo' WITH SECURITY_ENFORCED LIMIT 1];
    }


    public wrts_prcgvr__AsyncJob__c getAsyncJobByJobItem(String recordId){

        wrts_prcgvr__AsyncJob__c asyncJobRec = new wrts_prcgvr__AsyncJob__c();

        try{
            
            asyncJobRec = [SELECT Id, 
        wrts_prcgvr__Details__c,
        wrts_prcgvr__Status__c
        FROM wrts_prcgvr__AsyncJob__c
        WHERE wrts_prcgvr__JobItem__c = :recordId
        AND (wrts_prcgvr__Status__c = 'Completed'
        
            OR wrts_prcgvr__Status__c = 'Queued')
        WITH SECURITY_ENFORCED
        LIMIT 1];

        }catch(Exception e){

            System.debug(e.getMessage());

        }

        return asyncJobRec;

    }

}
