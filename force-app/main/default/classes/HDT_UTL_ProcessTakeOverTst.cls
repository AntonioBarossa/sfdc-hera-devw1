@isTest
public with sharing class HDT_UTL_ProcessTakeOverTst {
    @isTest
    public static void testSubentroKO(){
        String processName='Subentro';

        String dataLead = 'Titolare,Bianchi,Mario Rossi SAS,1327650667,1327650667,CLIENTI GENERICI 20%,Azienda,Aziende Soho,HERA COMM,+39,3440418691,+39,null,,null,854455666,2015-12-31,Napoli,Maschio,Test,null,,VIA DELLA VITTORIA,MORINO,67050,ITALIA,AQ,null,,8,null,NA,80014,true,Back office,null,,Ester,Verdi,null,,WITEL SRL UNIPERSONALE,Energia Elettrica,IT001E68971403,0011X00000lNMPAQA4,Domestico,13A0-Usi di Abitazione BT,1500,Libero,null,,Si,null,,true,3,150,330,BT,Si,Monofase,Monorario,null,,null,,null,,Bologna,1,10,true,RID,null,,null,,false,IT98C0987612345098765987123,IT,98,C,9876,12345,98765987123,Stesso Sottoscrittore,Marta,Esposito,STTCFR80A01F205Q,null,,null,MORINO,VIA DELLA VITTORIA,2,false,null,Vocal Order,E-Mail,Ordinaria (Perm),Si,2,Permanente,null,621458596,null,999999,Si,621458596,null,75,null,,Iva 22% (Cod. 02),2021-09-15,Draft,Analisi Consumi,null,,null,100,4,Si,Appartamento,null,2021-04-26'                                                                                                      ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
      
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }
    @isTest
    public static void testSubentro1(){
        String processName='Subentro';

        String dataLead = 'Titolare,Bianchi,Mario Rossi SAS,1327650667,1327650667,CLIENTI GENERICI 20%,Azienda,Aziende Soho,HERA COMM,+39,3440418691,+39,null,,null,854455666,2015-12-31,Napoli,Maschio,Business,null,,VIA DELLA VITTORIA,MORINO,67050,ITALIA,AQ,null,,8,null,NA,80014,true,Back office,null,,Ester,Verdi,null,,WITEL SRL UNIPERSONALE,Energia Elettrica,IT001E68971403,0011X00000lNMPAQA4,Domestico,13A0-Usi di Abitazione BT,1500,Libero,null,,Si,null,,true,3,150,330,BT,Si,Monofase,Monorario,null,,null,,null,,Bologna,1,10,true,RID,null,,null,,false,IT98C0987612345098765987123,IT,98,C,9876,12345,98765987123,Stesso Sottoscrittore,Marta,Esposito,STTCFR80A01F205Q,null,,null,MORINO,VIA DELLA VITTORIA,2,false,null,Vocal Order,E-Mail,Ordinaria (Perm),Si,2,Permanente,null,621458596,null,999999,Si,621458596,null,75,null,,Iva 22% (Cod. 02),2021-09-15,Draft,Analisi Consumi,null,,null,100,4,Si,Appartamento,null,2021-04-26'                                                                                                      ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
        System.debug('ms'+ms);

        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);

    }
    @isTest
    public static void testSubentro2(){
        String processName='Subentro';
        Account accBusiness= HDT_UTL_DataFactoryTst.createAccountBusiness(1,false,'HERA COMM','Azienda','Aziende Soho').get(0);
        accBusiness.VATNumber__c='1327650667';
        insert accBusiness;
        String dataLead = 'Titolare,Bianchi,Mario Rossi SAS,1327650667,1327650667,CLIENTI GENERICI 20%,Azienda,Aziende Soho,HERA COMM,+39,3440418691,+39,null,,null,854455666,2015-12-31,Napoli,Maschio,Business,null,,VIA DELLA VITTORIA,MORINO,67050,ITALIA,AQ,null,,8,null,NA,80014,true,Back office,null,,Ester,Verdi,null,,WITEL SRL UNIPERSONALE,Energia Elettrica,IT001E68971403,0011X00000lNMPAQA4,Domestico,13A0-Usi di Abitazione BT,1500,Libero,null,,Si,null,,true,3,150,330,BT,Si,Monofase,Monorario,null,,null,,null,,Bologna,1,10,true,RID,null,,null,,false,IT98C0987612345098765987123,IT,98,C,9876,12345,98765987123,Stesso Sottoscrittore,Marta,Esposito,STTCFR80A01F205Q,null,,null,MORINO,VIA DELLA VITTORIA,2,false,null,Vocal Order,E-Mail,Ordinaria (Perm),Si,2,Permanente,null,621458596,null,999999,Si,621458596,null,75,null,,Iva 22% (Cod. 02),2021-09-15,Draft,Analisi Consumi,null,,null,100,4,Si,Appartamento,null,2021-04-26'                                                                                                      ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id)                                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
      System.debug('ms'+ms);
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }
}
