public inherited sharing class HDT_QR_HerokuPostSalesManager {

    public Case getCurrentCaseById(String recordId){

        Case currentCase = new Case();

        try{

            currentCase = [SELECT Id, 
            Phase__c, 
            Type,
            CaseNumber, 
            RecordTypeId 
            FROM Case 
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1];

        } catch(Exception e){

            System.debug(e.getMessage());

        }

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


    public List<wrts_prcgvr__AsyncJob__c> getAsyncJobByJobItem(String recordId){

        List<wrts_prcgvr__AsyncJob__c> asyncJobList = new List<wrts_prcgvr__AsyncJob__c>();

        try{
            
            asyncJobList = [SELECT Id
        FROM wrts_prcgvr__AsyncJob__c
        WHERE wrts_prcgvr__JobItem__c = :recordId
        AND wrts_prcgvr__Status__c = 'Completed'
        WITH SECURITY_ENFORCED];

        }catch(Exception e){

            System.debug(e.getMessage());

        }

        return asyncJobList;

    }

}
