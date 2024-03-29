@isTest
public with sharing class HDT_UTL_ProcessLeadTst {

    private final static String dataLeadOk='HERA COMM|HCM|null|347852147|null|null|Mario|Rossi|Laurea|Studente|Benedetto Brin|1|80100|80100|Napoli|NA|null|null|null|null|25|null|Maschio|null|SI|1|2020-10-1|Webform callback|AAA|sito standard|NO|1|2020-10-1|Webform callback|HCM|sito standard|null|null|null|null|2020-10-1|null|null|null|null|null|null|null|null|null|test';
    private final static String dataLeadKo='HERA COMM|HCM|084588559|3485555555|test@mail.com|null|null|null|Laurea|Studente|Benedetto Brin|1|80100|80100|Napoli|NA|null|null|null|null|25|null|Maschio|null|SI|null|null|null|null|null|NO|null|null|null|null|null|sito standard|null|null|null|null|2020-10-11,null|null|null|null|null|null|null|null|null|test';

    @isTest
    public static void testLeadOK(){
        String processName='Lead';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLeadOk});
        test.startTest();
            HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName); 
            Database.executeBatch(processReq,1);
                
        test.stopTest();
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
  
        System.assertEquals('Chiuso', ms.Status__c,  ms.Status__c);
    }
    
    @isTest
    public static void testLeadOKUpdate(){
        String processName='Lead';
        Lead myLead=HDT_UTL_DataFactoryTst.createLead(1,false).get(0);
        myLead.FirstName        = 'Mario'    ;
        myLead.LastName         = 'Rossi'   ;
        myLead.CompanyOwner__c  = 'HERA COMM';
        insert myLead;
        
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLeadOk});
        test.startTest();
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName); 
        Database.executeBatch(processReq,1);
        test.stopTest();
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
        
        System.assertEquals('Chiuso', ms.Status__c,  ms.Status__c);


    }
    @isTest
    public static void testLeadKO(){
        String processName='Lead';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLeadKo});
        test.startTest()                                                                                                      ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                          ; 
        Database.executeBatch(processReq,1)                                                                                   ;
        test.stopTest()                                                                                                       ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
       
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);


    }
}
