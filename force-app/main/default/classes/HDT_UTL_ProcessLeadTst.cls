public with sharing class HDT_UTL_ProcessLeadTst {
    @isTest
    public static void testLeadOK(){
        String processName='Lead';
        String dataLead='HERA COMM,HCM,84588559,3485555555,test@mail.com,null,Rossi,Mario,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-11,Webform callback,AAA,sito standard,NO,1,11-10-2020,Webform callback,HCM,sito standard,sito standard,null,,null,,2020-10-11,null,,null,,null,,null,,null,test';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead});
        test.startTest();
            HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id); 
            Database.executeBatch(processReq,1);
                
        test.stopTest();
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
  
        System.assertEquals('Chiuso', ms.Status__c,  ms.Status__c);
    }
    
    @isTest
    public static void testLeadOKUpdate(){
        String processName='Lead';
        String dataLead='HERA COMM,HCM,84588559,3485555555,test@mail.com,null,Rossi,Mario,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-11,Webform callback,AAA,sito standard,NO,1,11-10-2020,Webform callback,HCM,sito standard,sito standard,null,,null,,2020-10-11,null,,null,,null,,null,,null,test';
        Lead myLead=HDT_UTL_DataFactoryTst.createLead(1,false).get(0);
        myLead.FirstName        = 'Mario'    ;
        myLead.LastName         = 'Rossi'   ;
        myLead.CompanyOwner__c  = 'HERA COMM';
        insert myLead;
        
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead});
        test.startTest();
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id); 
        Database.executeBatch(processReq,1);
        test.stopTest();
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
        
        System.assertEquals('Chiuso', ms.Status__c,  ms.Status__c);


    }
    @isTest
    public static void testLeadKO(){
        String processName='Lead';
        String dataLead='HERA COMM,HCM,084588559,3485555555,test@mail.com,null,null,null,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,null,,null,,null,NO,null,,null,,null,sito standard,null,,null,,2020-10-11,null,,null,,null,,null,,null,test';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead});
        test.startTest()                                                                                                      ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                          ; 
        Database.executeBatch(processReq,1)                                                                                   ;
        test.stopTest()                                                                                                       ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
       
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);


    }
}
