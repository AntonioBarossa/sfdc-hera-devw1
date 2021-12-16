@IsTest
public with sharing class HDT_AppointmentAgendaEventTest {
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,true,acctList[0].Id);
    }

    @IsTest
    public static void createPlatformEvent(){
        String methodName = 'createPlatformEvent: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Completed';
        HDT_PEV_AppointmentAgenda__e activityEvent = new HDT_PEV_AppointmentAgenda__e();
        activityEvent.Activity_JSON__c = JSON.serialize(activity);
        Test.startTest();
            Database.SaveResult sr = EventBus.publish(activityEvent);
        Test.stopTest();
        activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Completed', activity.wrts_prcgvr__Status__c, methodName+'Cambio Stato non effettuato');    
    }
    
}
