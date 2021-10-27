@isTest
public with sharing class HDT_UTL_ProcessExecutionTst {
     
    @isTest
    public static void test1(){
        String processName='Subentro';
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VerifIndirizzo','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        String dataLead = 'Titolare,Bianchi,Mario Rossi SAS,1327650667,1327650667,CLIENTI GENERICI 20%,Azienda,Aziende Soho,HERA COMM,+39,3440418691,+39,null,,null,854455666,2015-12-31,Napoli,Maschio,Test,null,,VIA DELLA VITTORIA,MORINO,67050,ITALIA,AQ,null,,8,null,NA,80014,true,Back office,null,,Ester,Verdi,null,,WITEL SRL UNIPERSONALE,Energia Elettrica,IT001E68971403,0011X00000lNMPAQA4,Domestico,13A0-Usi di Abitazione BT,1500,Libero,null,,Si,null,,true,3,150,330,BT,Si,Monofase,Monorario,null,,null,,null,,Bologna,1,10,true,RID,null,,null,,false,IT98C0987612345098765987123,IT,98,C,9876,12345,98765987123,Stesso Sottoscrittore,Marta,Esposito,STTCFR80A01F205Q,null,,null,MORINO,VIA DELLA VITTORIA,2,false,null,Vocal Order,E-Mail,Ordinaria (Perm),Si,2,Permanente,null,621458596,null,999999,Si,621458596,null,75,null,,Iva 22% (Cod. 02),2021-09-15,Draft,Analisi Consumi,null,,null,100,4,Si,Appartamento,null,2021-04-26'                                                                                                      ;
        HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead})        ;
        
        MassiveLoaderRequestItem__c ms=[select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c,MassiveLoaderRequest__r.ProcessType__c from MassiveLoaderRequestItem__c ];
        HDT_UTL_ProcessExecution pr =new HDT_UTL_ProcessExecution();
        Test.startTest();
        pr.setMassiveLoaderRequestItem(ms);
        pr.execute();
        Account accBusiness= HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende Soho').get(0);
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,true,accBusiness.id,'Bozza');
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
        pr.currentProcess.currentChildOrder=orders.get(0);
        pr.currentProcess.currentServicePoint=points.get(0).clone(false, false, false, false);
        pr.currentProcess.currentAccount=accBusiness;
        pr.makeFatherOrder();
        pr.currentProcess.currentChildOrder.ProcessType__c='Voltura';
        pr.makeServiceRequest();
        //System.assertEquals(pr.currentProcess.currentServicePoint.Account__c , pr.currentProcess.currentChildOrder.AccountId, pr.currentProcess.currentChildOrder.AccountId);
        pr.makeContact();
        List <HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj> listAdd=new List <HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj> ();
        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj addObj=new HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj();
        addObj.city1        ='Napoli'       ;
        addObj.postCode1     ='80100'       ;
        addObj.cityPCode    ='08566655440'  ;
        addObj.houseNum1    ='1'            ;
        addObj.region       ='Campania'     ;
        addObj.street       ='Napoli'       ;
        listAdd.add(addObj);
        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj addObj2=new HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj();
        addObj2.city1        ='Napoli'       ;
        addObj2.postCode1    ='80101'        ;
        addObj2.cityPCode    ='08566655450'  ;
        addObj2.houseNum1    ='2'            ;
        addObj2.region       ='Campania'     ;
        addObj2.street       ='Roma'         ;
        listAdd.add(addObj2);
        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj myAdd=pr.analizeRespVerifyAddress(listAdd,'Napoli','Napoli','1','80100');
        System.assertEquals('1', myAdd.houseNum1, '1');
        
        pr.getTypeField('Case','Status');
        pr.getTypeField('Opportunity','Amount');
        pr.getTypeField('Contact','Phone');
        pr.getTypeField('Account','DataEnrichmentLastUpdate__c');
        System.assertEquals('PICKLIST', pr.getTypeField('Case','Status'), 'PICKLIST');
        new HDT_UTL_ProcessExecution.HDT_WRP_ProcessEntitiesException('test','test');

        Test.stopTest();
        
        
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

        
        System.assertEquals('Errore', ms.Status__c,  ms.Status__c);
        
    }
    @isTest
    public static void testLeadOK(){
        String processName='Lead';
        String dataLead='HERA COMM,HCM,null,347852147,null,,Mario,Rossi,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-1,Webform callback,AAA,sito standard,NO,1,2020-10-1,Webform callback,HCM,sito standard,null,,null,,2020-10-1,null,,null,,null,,null,,null,test';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{dataLead});
        test.startTest();
            HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(req.Id); 
            Database.executeBatch(processReq,1);
                
        test.stopTest();
        MassiveLoaderRequestItem__c ms=[SELECT  Id, IsDeleted, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, StatusDescription__c, Status__c FROM MassiveLoaderRequestItem__c   WHERE MassiveLoaderRequest__c=:req.Id];
  
        System.assertEquals('Chiuso', ms.Status__c,  ms.Status__c);
    }
    
}
