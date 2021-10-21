@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_KpiTracking {
    public static void createKpiTracking(List<Account> accountList, Map<Id,Sobject> accountOldMap){
        List<KpiTracking__c> kpiList = new List<KpiTracking__c>();
        Map<String,Account> accountMap = new Map<String,Account>();
        KpiTracking__c singleKpi;
        for (Account singleAccount : accountList) {
            if(accountOldMap != null){
                Account oldAccount = (Account) accountOldMap.get(singleAccount.Id);
                if((singleAccount.CustomerCode__c != null && oldAccount.CustomerCode__c != singleAccount.CustomerCode__c) || (singleAccount.CustomerCode__c != null &&  String.isBlank(singleAccount.KpiTracking__c))){
                    accountMap.put(singleAccount.CustomerCode__c, singleAccount);
                    singleKpi = newInstanceRecord(singleAccount);
                    kpiList.add(singleKpi);
                }
            }else if(singleAccount.CustomerCode__c != null && singleAccount.CustomerCode__c != ''){
                accountMap.put(singleAccount.CustomerCode__c, singleAccount);
                singleKpi = newInstanceRecord(singleAccount);
                kpiList.add(singleKpi);
            }
        }
        
        try {
            if (KpiTracking__c.SObjectType.getDescribe().isAccessible() && KpiTracking__c.SObjectType.getDescribe().isCreateable()) {
                //HDT_UTL_DatabaseService.insertSObject(kpiList);
                HDT_UTL_DatabaseService.upsertSObjectExternalId(kpiList, 'KpiTracking__c', 'CustomerCode__c');
                for(KpiTracking__c kpi : kpiList){
                    accountMap.get(kpi.CustomerCode__c).KpiTracking__c = kpi.Id;
                }
            }
        } catch (DmlException ex) {
            System.debug(LoggingLevel.DEBUG, 'Non è stato possibile creare il KPI');
        }
    }

    private static KpiTracking__c newInstanceRecord(Account acc){
        KpiTracking__c singleKpi;
        if(acc.CustomerCode__c != null && String.isNotBlank(acc.CustomerCode__c)){
            singleKpi = new KpiTracking__c();
            singleKpi.CustomerCode__c = acc.CustomerCode__c;
            //singleKpi.Account__c = acc.Id;
        }
        return singleKpi;
    }

    public static void deleteKpiTracking(List<Account> accountList){
        List<KpiTracking__c> kpiList = new List<KpiTracking__c>();
        KpiTracking__c singleKpi;
        for (Account singleAccount : accountList) {
            if(singleAccount.KpiTracking__c != null){
                singleKpi = new KpiTracking__c();
                singleKpi.Id = singleAccount.KpiTracking__c;
                kpiList.add(singleKpi);
            }
        }
        if(kpiList != null && kpiList.size()>0){
            try {
                HDT_UTL_DatabaseService.deleteSObject(kpiList);
            } catch (DmlException ex) {
                System.debug(LoggingLevel.DEBUG, 'Non è stato possibile cancellare i KPI');
            }
        }
    }
    public static void updateKpiRecord(KpiTracking__c record){
        try {
            if(KpiTracking__c.SObjectType.getDescribe().isAccessible() && KpiTracking__c.SObjectType.getDescribe().isUpdateable()){
                HDT_UTL_DatabaseService.updateSObject(record);
            }
        } catch (DmlException ex) {
            System.debug(LoggingLevel.DEBUG, 'Error updating kpi');
        }
    }
    public static List<KpiTracking__c> getKpiRecord(String params){
        if(params != null){
            if(params instanceOf Id){
                return [SELECT Id, LastBillAmount__c,LastBillNumber__c,LastBillExpirationDate__c,LastBillPaymentStatus__c,LastBillCommodity__c,LastBillLastUpdate__c FROM KpiTracking__c WHERE Id =:params WITH SECURITY_ENFORCED];
            }else {
                return [SELECT Id, LastBillAmount__c,LastBillNumber__c,LastBillExpirationDate__c,LastBillPaymentStatus__c,LastBillCommodity__c,LastBillLastUpdate__c FROM KpiTracking__c WHERE CustomerCode__c =:params WITH SECURITY_ENFORCED];
            }
        }else {
            return new List<KpiTracking__c>();
        }
    }
}
