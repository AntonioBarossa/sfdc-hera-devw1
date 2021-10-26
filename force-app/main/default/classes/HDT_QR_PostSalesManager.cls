@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_QR_PostSalesManager {

    public Integer checkLocalDispatcher(String dispatcherName){

        return [SELECT COUNT() 
        FROM HDT_LocalDispatcherInrete__mdt 
        WHERE DispatcherDesc__c = :dispatcherName
        WITH SECURITY_ENFORCED]; 

    }


    public wrts_prcgvr__ActivityTemplate__c getActivityTemplate(String template){

        return [SELECT Id,
        wrts_prcgvr__Assignees__c,
        wrts_prcgvr__Subject__c,
        wrts_prcgvr__DueDateField__c
        FROM wrts_prcgvr__ActivityTemplate__c
        WHERE Name = :template
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }

    public Case getCaseByServicePoint(String type, String servicePoint){
        Case c = new Case();
        try{
           c = [SELECT Id,
            Phase__c
            FROM Case
            WHERE ServicePoint__c = :servicePoint
            AND Type = :type
            AND Status != 'Closed'
            WITH SECURITY_ENFORCED
            LIMIT 1];
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'HDT_QR_PostSalesManage Exception -> ' + e.getMessage());
        }
        return c;
    }

}
