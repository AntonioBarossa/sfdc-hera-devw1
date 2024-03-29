@isTest
public with sharing class HDT_BA_ProcessRequestItemTst {  
    
    private final static String dataLeadOk='HERA COMM|HCM|null|347852147|null|null|Mario|Rossi|Laurea|Studente|Benedetto Brin|1|80100|80100|Napoli|NA|null|null|null|null|25|null|Maschio|null|SI|1|2020-10-1|Webform callback|AAA|sito standard|NO|1|2020-10-1|Webform callback|HCM|sito standard|null|null|null|null|2020-10-1|null|null|null|null|null|null|null|null|null|test';
    private final static String subentroOk = 'Titolare|Bianchi|Mario Rossi SAS|1327650667|1327650667|CLIENTI GENERICI 20%|Azienda|Aziende Soho|HERA COMM|+39|3440418691|+39|null|null|null|854455666|2015-12-31|Napoli|Maschio|Business|null|null|VIA DELLA VITTORIA|MORINO|67050|ITALIA|AQ|null|null|8|null|NA|80014|true|Back office|null|null|Ester|Verdi|null|null|WITEL SRL UNIPERSONALE|Energia Elettrica|IT001E68971403|0011X00000lNMPAQA4|Domestico|13A0-Usi di Abitazione BT|1500|Libero|null|null|Si|null|null|true|3|150|330|BT|Si|Monofase|Monorario|null|null|null|null|null|null|Bologna|1|10|true|RID|null|null|null|null|false|IT98C0987612345098765987123|IT|98|C|9876|12345|98765987123|Stesso Sottoscrittore|Marta|Esposito|STTCFR80A01F205Q|null|null|null|MORINO|VIA DELLA VITTORIA|2|false|null|Vocal Order|E-Mail|Ordinaria (Perm)|Si|2|Permanente|null|621458596|null|999999|Si|621458596|null|75|null|null|Iva 22% (Cod. 02)|2021-09-15|Draft|Analisi Consumi|null|null|null|100|4|Si|Appartamento|null|2021-04-26';
    private final static String dataLeadKo='HERA COMM|HCM|084588559|3485555555|test@mail.com|null|null|null|Laurea|Studente|Benedetto Brin|1|80100|80100|Napoli|NA|null|null|null|null|25|null|Maschio|null|SI|null|null|null|null|null|NO|null|null|null|null|null|sito standard|null|null|null|null|2020-10-11|null|null|null|null|null|null|null|null|null|test';
    private final static String subentroKo = 'Titolare|Bianchi|Mario Rossi SAS|1327650667|1327650667|CLIENTI GENERICI 20%|Azienda|Aziende Soho|HERA COMM|+39|3440418691|+39|null|null|null|854455666|2015-12-31|Napoli|Maschio|Test|null|null|VIA DELLA VITTORIA|MORINO|67050|ITALIA|AQ|null|null|8|null|NA|80014|true|Back office|null|null|Ester|Verdi|null|null|WITEL SRL UNIPERSONALE|Energia Elettrica|IT001E68971403|0011X00000lNMPAQA4|Domestico|13A0-Usi di Abitazione BT|1500|Libero|null|null|Si|null|null|true|3|150|330|BT|Si|Monofase|Monorario|null|null|null|null|null|null|Bologna|1|10|true|RID|null|null|null|null|false|IT98C0987612345098765987123|IT|98|C|9876|12345|98765987123|Stesso Sottoscrittore|Marta|Esposito|STTCFR80A01F205Q|null|null|null|MORINO,VIA DELLA VITTORIA|2|false|null|Vocal Order|E-Mail|Ordinaria (Perm)|Si|2|Permanente|null|621458596|null|999999|Si|621458596|null|75|null|null|Iva 22% (Cod. 02)|2021-09-15|Draft|Analisi Consumi|null|null|null|100|4|Si|Appartamento|null|2021-04-26';


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
    /*@isTest
    public static void testRilavorazioneScartiOK(){
        String processName='RilavorazioneScarti';
        Account acc     = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti').get(0);
        Order ord       = HDT_UTL_DataFactoryTst.createOrder(1,true,acc.id,'Bozza').get(0)                                            ;
        String dataLead = [SELECT Id ,orderNumber FROM Order WHERE Id=:ord.Id].get(0).orderNumber                                     ;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                                  ; 
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
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                                  ; 
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
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                                  ; 
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
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
      
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }*/
    @isTest
    public static void testSubentroKO(){
        String processName='Subentro';

        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{subentroKo})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
      
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }
    @isTest
    public static void testSubentroOK1(){
        String processName='Subentro';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{subentroOk})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);

    }
    @isTest
    public static void testSubentroOK2(){
        String processName='Subentro';
        Account accBusiness= HDT_UTL_DataFactoryTst.createAccountBusiness(1,false,'HERA COMM','Azienda','Aziende Soho').get(0);
        accBusiness.VATNumber__c='1327650667';
        insert accBusiness;
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{subentroOk})        ;
        test.startTest()                                                                                                              ;
        HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id, 1, processName)                                  ; 
        Database.executeBatch(processReq,1)                                                                                           ;
        test.stopTest()                                                                                                               ;
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];

        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
    }
}
