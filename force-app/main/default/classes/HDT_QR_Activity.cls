/**
* @author Luca Molino (Luca.Molino@dunegroup.it)
* @date 15/08/21
* @description HDT_QR_Activity
* @history Luca Molino – 15/08/21 – created class
*/
public inherited sharing class HDT_QR_Activity {

    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    String fields= 'Id, OwnerId, Name, RecordTypeId, CreatedDate, Type__c,Account__c,Approved__c';
    
    public HDT_QR_Activity() {
        System.debug('HDT_QR_Activity empty constructor');
    }

    @SuppressWarnings('PMD.UnusedLocalVariable') //* Andrei Necsulescu -- supressed PMD warning since it's a false positive 
    public wrts_prcgvr__Activity__c getLastActivity(String idAcc,SObject o){
        activitySrv.checkReadAccess(fields);

        String saleId =  (String)o.get('Id');

        String type = 'Approvazione Offerte';
        String status ='Aperta';
        String query = 'SELECT '+ fields +
                ' FROM wrts_prcgvr__Activity__c WHERE Type__c=: type AND Account__c =: idAcc AND wrts_prcgvr__Status__c =: status AND Sale__c=: saleId WITH SECURITY_ENFORCED';

        List<wrts_prcgvr__Activity__c> activityList = Database.query(query);
        
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();

        if (!activityList.isEmpty()) {
            activity = activityList[0];
        }
        
        return activity;
    }

    public static List<wrts_prcgvr__Activity__c> getActivityFromIdList(Set<String> actIdSet){
        
        List<wrts_prcgvr__Activity__c> actList = new List<wrts_prcgvr__Activity__c>();

        actList = [SELECT Id, RecordTypeId, Order__c, Order__r.Id, Order__r.AgencyCode__c, Order__r.RecordType.DeveloperName FROM wrts_prcgvr__Activity__c WHERE Id = :actIdSet WITH SECURITY_ENFORCED];

        return actList;
    }


    /**
    * @author Marco Arci (marco.arci@webresults.it)
    * @description metodo per prelevare le activity del tipo scelto e correlate ai parent passati come parametri
    * @date 18/05/2022
    * @param1 List<String> lista di Id dei parent delle activity (Case o Order)
    * @param2 List<Case> lista dei tipi di activiti che si vogliono cercare
    */
    public static List<wrts_prcgvr__Activity__c> getActivityFromTypeList(List<String> parentIds, Set<String> actTypes){
        
        List<wrts_prcgvr__Activity__c> actList = new List<wrts_prcgvr__Activity__c>();
        String nameObject = ((Id)parentIds[0]).getSObjectType().getDescribe().getName();
        if('Case'.equalsIgnoreCase(nameObject)){
            actList = [SELECT Id, RecordTypeId, Case__c, Case__r.RecordType.DeveloperName, Order__c, Order__r.Id, Order__r.AgencyCode__c, Order__r.RecordType.DeveloperName 
                       FROM wrts_prcgvr__Activity__c 
                       WHERE Type__c = :actTypes
                       AND Case__c = :parentIds
                       WITH SECURITY_ENFORCED];
        }else if('Order'.equalsIgnoreCase(nameObject)){
            actList = [SELECT Id, RecordTypeId, Case__c, Case__r.RecordType.DeveloperName, Order__c, Order__r.Id, Order__r.AgencyCode__c, Order__r.RecordType.DeveloperName 
                       FROM wrts_prcgvr__Activity__c 
                       WHERE Type__c = :actTypes
                       AND Order__c = :parentIds
                       WITH SECURITY_ENFORCED];
        }

        return actList;
    }
}