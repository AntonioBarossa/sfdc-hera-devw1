@isTest
public with sharing class HDT_SCH_ProcessRequestItemTst {
  @isTest
  public static void test(){
    String processName='Lead';
    String dataLead='HERA COMM,HCM,084588559,3485555555,test@mail.com,null,null,null,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,null,,null,,null,NO,null,,null,,null,sito standard,null,,null,,2020-10-11,null,,null,,null,,null,,null,test';
    HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead});
    String crono = '20 30 8 10 2 ?';
    test.startTest();
        HDT_SCH_ProcessRequestItem m=new HDT_SCH_ProcessRequestItem();
        System.schedule('Label of the job', crono , m);

        test.stopTest();
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
  }
}
