@isTest
public with sharing class HDT_SCH_UpdateActivitiesStatusTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void makedata(){
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

        HDT_UTL_DataFactoryTst.pClickInstance();
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);

        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;  
        System.runAs(internalUser){
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
            activity[0].Type__c='Chiamata inbound';
            activity[0].wrts_prcgvr__Status__c = 'Aperta' ;
            insert activity;
            Datetime yesterday = Datetime.now().addDays(-1);
            Test.setCreatedDate(activity[0].Id, yesterday);
        }
    }


@isTest
static void test(){

    String CRON_EXP = '20 30 8 10 2 ?';
    Test.startTest();
    HDT_SCH_UpdateActivitiesStatus sch = new HDT_SCH_UpdateActivitiesStatus();
    System.schedule('Label of the job', CRON_EXP , sch);
    Test.stopTest();
    
    List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    
    List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
}

}