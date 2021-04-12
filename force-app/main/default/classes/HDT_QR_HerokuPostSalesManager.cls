public inherited sharing class HDT_QR_HerokuPostSalesManager {

    public Case getCurrentCaseById(String recordId){

        Case currentCase = new Case();

        currentCase = [SELECT Id, 
        Phase__c, 
        Type,
        CaseNumber, 
        RecordTypeId,
        HerokuPracticeCode__c
        FROM Case 
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];

        return currentCase;

    }

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
