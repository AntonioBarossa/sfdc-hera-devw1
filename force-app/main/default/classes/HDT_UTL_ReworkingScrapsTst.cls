@isTest
public with sharing class HDT_UTL_ReworkingScrapsTst {
    @isTest
    public static void testRilavorazioneScartiOK(){
        String processName='RilavorazioneScarti';
        Account acc     = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti').get(0);
        Order ord       = HDT_UTL_DataFactoryTst.createOrder(1,true,acc.id,'Bozza').get(0)                                            ;
        String dataLead = [SELECT Id ,orderNumber FROM Order WHERE Id=:ord.Id].get(0).orderNumber                                     ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
      
        System.assertEquals('Chiuso', ms.Status__c,  ms.Status__c);
    }
    @isTest
    public static void testRilavorazioneScartiKO(){
        String processName='RilavorazioneScarti';

        String dataLead = 'null'                                                                                                      ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
       
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }
    @isTest
    public static void testRilavorazioneScartiKO2(){
        String processName='RilavorazioneScarti';

        String dataLead = 'C-'                                                                                                        ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
       
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }
    @isTest
    public static void testRilavorazioneScartiKO3(){
        String processName='RilavorazioneScarti';

        String dataLead = 'O-'                                                                                                        ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
      
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }
}
