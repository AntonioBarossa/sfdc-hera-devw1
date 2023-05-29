@istest
public with sharing class HDT_BA_DeleteServicePointsTst {
    @TestSetup
    static void makeData(){
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(10,true);
        for(ServicePoint__c servPoint : points ){
            servPoint.SAPImplantCode__c = null;
            servPoint.CommoditySector__c = 'Ambiente';
        }
        update points;
    }
    @isTest
    static void testexecute(){
        Test.startTest();
        Database.executeBatch(new HDT_BA_DeleteServicePoints());
        Test.stopTest();

        String n = Label.HDT_DeleteServicePointDays;
        List <ServicePoint__c> servpoint = Database.query('SELECT Id FROM ServicePoint__C where SAPImplantCode__c = null and CommoditySector__c = \'Ambiente\' and createdDate <= LAST_N_DAYS:' + Label.HDT_DeleteServicePointDays);

        System.assertEquals(0,servPoint.size(),'HDT_BA_DeleteServicePoints has not been well functioned');
        BatchExecutionKpiConfiguration__mdt kpiMeta = [SELECT DesiredEmail__c, EnableEmailSend__c, EnableTracking__c  FROM BatchExecutionKpiConfiguration__mdt WHERE BatchName__c='HDT_BA_DeleteServicePoints' limit 1];
        if(kpiMeta!=null&&kpiMeta.EnableTracking__c){
            BatchExecutionKpi__c check = [SELECT Id, NumOfRecords__c FROM BatchExecutionKpi__c LIMIT 1];
            System.assertEquals(10,check.NumOfRecords__c,'Something went wrong');
        }
    }
}
