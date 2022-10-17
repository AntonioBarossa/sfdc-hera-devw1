//Copertura classe di test HDT_UTL_DoubleCalloutPreventionTst
public with sharing class HDT_QR_DoubleCalloutPrevention {
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static Map<Id, List<wrts_prcgvr__AsyncJob__c>> getExistingCalloutByJobItem(Map<String,Object> args){
        try{
            Set<Id> recordIdList = (Set<Id>)args.get('recordIdList');
            Set<String> apexClasses = (Set<String>)args.get('apexClasses');
            Set<String> methods = (Set<String>)args.get('methods');
            String objectType = (String)args.get('objectName');
            Datetime lastJobDate = (Datetime)args.get('date');
            Map<Id, List<wrts_prcgvr__AsyncJob__c>> jobItemAsyncJobsMap = new Map<Id, List<wrts_prcgvr__AsyncJob__c>>();
            for (wrts_prcgvr__AsyncJob__c asyncJob : [SELECT Id,wrts_prcgvr__JobItem__c, wrts_prcgvr__MethodName__c, wrts_prcgvr__Arguments__c,wrts_prcgvr__ApexClassName__c
                    FROM wrts_prcgvr__AsyncJob__c 
                    WHERE wrts_prcgvr__ApexClassName__c IN :apexClasses 
                    AND wrts_prcgvr__JobItem__c IN : recordIdList
                    AND wrts_prcgvr__JobType__c = 'Callout'
                    AND wrts_prcgvr__ObjectType__c = :objectType
                    AND wrts_prcgvr__MethodName__c IN : methods
                    AND CreatedDate >= :lastJobDate
                    WITH SECURITY_ENFORCED])
            {
                if (!jobItemAsyncJobsMap.containsKey(asyncJob.wrts_prcgvr__JobItem__c)){
                    jobItemAsyncJobsMap.put(asyncJob.wrts_prcgvr__JobItem__c, new List<wrts_prcgvr__AsyncJob__c>());
                }
                jobItemAsyncJobsMap.get(asyncJob.wrts_prcgvr__JobItem__c).add(asyncJob);
            }
            return jobItemAsyncJobsMap;
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'HDT_QR_DoubleCalloutPrevention.getExistingCallout error: ' +e.getMessage());
            return new Map<Id, List<wrts_prcgvr__AsyncJob__c>>();
        }
    }

    //Restituisce una mappa con chiave la fase di studio e valori i metodi di cui non deve esistere il job
    public static List<HDT_DoubleCalloutPrevention__mdt> getDoubleCalloutPreventionRecords(Set<String> phasesToCheck, Set<String> processTypeToCheck, String objectName){
        if (Test.isRunningTest()){
            return HDT_UTL_DoubleCalloutPreventionTst.getConfigRecordForTest().get(objectName);
        }
        return [
            SELECT Id, PhaseToCheck__c, MethodToCheck__c,ApexClass__c, Arguments__c, CheckOnPhaseStory__c
            FROM HDT_DoubleCalloutPrevention__mdt 
            WHERE ObjectName__c = : objectName 
            AND PhaseToCheck__c IN: phasesToCheck
            AND ProcessType__c IN: processTypeToCheck
            AND IsActive__c = true
            WITH SECURITY_ENFORCED
        ];
    }
}
