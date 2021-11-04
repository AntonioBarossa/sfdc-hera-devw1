@isTest
public with sharing class HDT_BA_ErrorRequestItemTst {
   @isTest
   public static void testOk(){
        String processName='Lead';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{'HERA COMM,HCM,null,347852147,null,,Mario,Rossi,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-1,Webform callback,AAA,sito standard,NO,1,2020-10-1,Webform callback,HCM,sito standard,null,,null,,2020-10-1,null,,null,,null,,null,,null,test'});
        List<MassiveLoaderRequestItem__c> listReqItem = [SELECT id ,Status__c FROM MassiveLoaderRequestItem__c];
        for (MassiveLoaderRequestItem__c temp : listReqItem) {
            temp.Status__c='Errore';
            temp.StatusDescription__c='Errore';
        }
        update listReqItem;
        test.startTest();
            HDT_BA_ErrorRequestItem processReq = new HDT_BA_ErrorRequestItem(req.Id); 
            Database.executeBatch(processReq,1);
        test.stopTest();

        List<ContentDocumentLink> query = [select Id from ContentDocumentLink where LinkedEntityId=:req.id];
    	System.assertEquals(1, query.size(), 'ContentDocumentLink not created');
        System.assertNotEquals(null, query, 'ContentDocumentLink not created');

   }

}