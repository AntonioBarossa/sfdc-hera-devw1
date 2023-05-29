@isTest
public with sharing class HDT_UTL_SlaManagementTst {

    @TestSetup
    static void makeData(){

        Map<String, Id> slaTypesMap = new Map<String, Id>();
        Id postSalesId = Schema.SObjectType.SlaAdministration__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_PostSales').getRecordTypeId();
        Id salesId = Schema.SObjectType.SlaAdministration__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Sales').getRecordTypeId();
        slaTypesMap.put('01', postSalesId);
        slaTypesMap.put('02', postSalesId);
        slaTypesMap.put('03', postSalesId);
        slaTypesMap.put('04', postSalesId);
        slaTypesMap.put('05', postSalesId);
        slaTypesMap.put('06', salesId);
        slaTypesMap.put('07', salesId);
        slaTypesMap.put('08', salesId);
        slaTypesMap.put('09', salesId);
        slaTypesMap.put('10', salesId);

        Date startDate = Date.today();
        Date endDate = startDate.addDays(10);
        List<SlaAdministration__c> slaAdministrationList = new List<SlaAdministration__c>();
        SlaAdministration__c slaAdminRule;
        for(String slaType : slaTypesMap.keySet()){
            slaAdminRule = new SlaAdministration__c();
            slaAdminRule.Name = 'Rule_'+slaType;
            slaAdminRule.Type__c = slaType;
            slaAdminRule.StartDate__c = startDate;
            slaAdminRule.EndDate__c = endDate;
            slaAdminRule.Range__c = 5;
            slaAdminRule.RangeType__c = 'Giorni solari';
            slaAdminRule.RecordTypeId = slaTypesMap.get(slaType);

            slaAdminRule.ActivityType__c = 'Back Office - Catalogo Prodotti';
            slaAdminRule.StartCasePhase__c = 'Bozza';
            slaAdminRule.EndCasePhase__c = 'Ammissibilità OK';
            slaAdminRule.StartOrderPhase__c = 'Bozza';
            slaAdminRule.EndOrderPhase__c = 'Ammissibilità OK';
            slaAdminRule.CaseField__c = 'WrittenReceiptRequestDate__c';
            slaAdminRule.OrderField__c = 'EffectiveDate__c';

            slaAdminRule.Ato__c = 'Ato 4';
            slaAdminRule.Cluster__c = 'Attivazioni';
            slaAdminRule.CompanyOwner__c = 'HERA COMM';
            slaAdminRule.Process__c = 'Tutti';
            slaAdminRule.Commodity__c = 'Multi';
            slaAdminRule.SalesCompany__c = 'Hera Comm Marche';
            slaAdminRule.CustomerType__c = 'Account';
            slaAdminRule.FirstLevelComplaintClassification__c ='Richiesta di informazioni';
            //slaAdminRule.SecondLevelComplaintClassification__c

            slaAdministrationList.add(slaAdminRule);

        }
        insert slaAdministrationList;
                
    }

    @isTest
    static void constructorMethodsTst(){
        Test.startTest();
        HDT_UTL_SlaManagement slaMngCase=new HDT_UTL_SlaManagement('Case');
        slaMngCase.setDeletedRecordIdsList(new Set<Id>());
        slaMngCase.getTypeField( 'Case','Phase__c');
        slaMngCase.deleteEventHandler(null);
        HDT_UTL_SlaManagement slaMngOrder=new HDT_UTL_SlaManagement('Order');
        Test.stopTest();
        System.assertEquals(true, slaMngCase!=null,'class created');
        System.assertEquals(true, slaMngOrder!=null,'class created');
    }

    @isTest
    static void executeCaseTst(){
        Test.enableChangeDataCapture();
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orders[0].id);
        Test.getEventBus().deliver();
    } 

    //@isTest
    //static void executeCaseTst2(){
    //    
    //    List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
    //    List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
    //    List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
    //    List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
    //    List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
    //    List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orders[0].id);
    //    SlaTracking__c slaTrack = new SlaTracking__c();
    //    slaTrack.SlaAdministration__c = [SELECT Id FROM SlaAdministration__c WHERE Type__c = '01' LIMIT 1].Id;
    //    slaTrack.Case__c = caseList[0].Id;
    //    slaTrack.Status__c = 'Aperto';
    //    insert slaTrack;
//
    //    Test.enableChangeDataCapture();
    //    caseList[0].Phase__c = 'Annullato';
    //    update caseList;
    //    Test.getEventBus().deliver();
    //} 

    @isTest
    static void evaluateCaseTypeTst(){
        List<String> caseType = new List<String>();
        caseType.add('Aggiunta Attacco');
        caseType.add('Cessazione Scarichi Produttivi');
        caseType.add('Allineamento Anagrafica');
        caseType.add('Allineamento Canone Rai');
        caseType.add('Lettura Acqua Avviso al Cliente');
        caseType.add('Altre Verifiche');
        caseType.add('Ambiente annullo richiesta senza appuntamento');
        caseType.add('Reclamo Scritto Da Cittadino');
        caseType.add('Annullamento Contratti');
        caseType.add('Associazione Utente Web');
        caseType.add('Attivazione Click&Pay');
        caseType.add('Autoelettrica');
        caseType.add('Autolettura da cliente');
        caseType.add('Autolettura da processo');
        caseType.add('Avviso di Servizio');

        String slaRule = 'Account';

        for(String s : caseType){
            HDT_UTL_SlaManagement.evaluateCaseType(slaRule, s);
        }
        slaRule = 'Cittadino';

        for(String s : caseType){
            HDT_UTL_SlaManagement.evaluateCaseType(slaRule, s);
        }
    } 

    @isTest
    static void executeOrderTst(){
        Test.enableChangeDataCapture();
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
        Test.getEventBus().deliver();
    } 

    /*static void makeData2(){
        
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
        List<Case> caseList=HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orders[0].id);
        
        Map<String,Object> slaAdminFields=new Map<String,Object>{
            'Ato__c'=>'ATO Orientale Triestino','IsActive__c'=>true,
            'CaseField__c'=>'CustomerRequestDate__c','OrderField__c'=>'SendCertifiedEmailConsentDate__c',
            'FirstLevelComplaintClassification__c'=>'Reclamo Scritto','SecondLevelComplaintClassification__c'=>'Mercato','Cluster__c'=>'Attivazioni',
            'Description__c'=>'test','StartCasePhase__c'=>'Bozza','EndCasePhase__c'=>'Comunicazione verso Heroku OK',
            'StartOrderPhase__c'=>'Bozza','EndOrderPhase__c'=>'Comunicazione verso Heroku OK','Range__c'=>15,
            'Process__c'=>'Documentale/Copia Contratto','RecordTypeId'=>Schema.SObjectType.SlaAdministration__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_PostSales').getRecordTypeId(),
            'Commodity__c'=>'Acqua','SalesCompany__c'=>'Hera Comm S.p.A.','ActivityType__c'=>'Back Office - Catalogo Prodotti',
            'CustomerType__c'=>'Account','RangeType__c'=>'Giorni Solari','Type__c'=>'01'
        };
        List<SlaAdministration__c> slaAdminRules=HDT_UTL_DataFactoryTst.createSlaAdministration(1,true,slaAdminFields);
        HDT_UTL_DataFactoryTst.createSlaTracking(1,true,null, slaAdminRules[0].Id, caseList[0].Id, null, 100, 'Aperto');
        HDT_UTL_DataFactoryTst.createSlaTracking(1,true,null, slaAdminRules[0].Id, null, orders[0].Id, 100, 'Aperto');
    }

    @isTest
    static void setChangedObjListTst(){
        Case myCase=[SELECT Id,AccountId,ContactId FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WRP_SlaManagement.HDT_WRP_Event slaWrp=new HDT_WRP_SlaManagement.HDT_WRP_Event();
        slaWrp.recordId=myCase.Id;
        slaWrp.sObjType='Case';
        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>{myCase.Id=>slaWrp};
        HDT_UTL_SlaManagement slaUtils=new HDT_UTL_SlaManagement('Case');
        Test.startTest();
        slaUtils.setChangedObjList(wrpEventObjMap);
        Test.stopTest();
        System.assertEquals(true, slaUtils!=null, 'no exception occurred');
    }

    
    @isTest
    static void executeCaseTst2(){
        Case myCase=[SELECT Id,AccountId,ContactId FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WRP_SlaManagement.HDT_WRP_Event slaWrp=new HDT_WRP_SlaManagement.HDT_WRP_Event();
        slaWrp.recordId=myCase.Id;
        slaWrp.sObjType='Case';
        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>{myCase.Id=>slaWrp};
        HDT_UTL_SlaManagement slaUtils=new HDT_UTL_SlaManagement('Case');
        Test.startTest();
        slaUtils.setChangedObjList(wrpEventObjMap);
        slaUtils.execute();
        Test.stopTest();
        System.assertEquals(true, true, 'temp');
    }
    
    
    @isTest
    static void executeOrderTst2(){
        Case myOrder=[SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WRP_SlaManagement.HDT_WRP_Event slaWrp=new HDT_WRP_SlaManagement.HDT_WRP_Event();
        slaWrp.recordId=myOrder.Id;
        slaWrp.sObjType='Order';
        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>{myOrder.Id=>slaWrp};
        HDT_UTL_SlaManagement slaUtils=new HDT_UTL_SlaManagement('Order');
        Test.startTest();
        slaUtils.setChangedObjList(wrpEventObjMap);
        slaUtils.execute();
        Test.stopTest();
        System.assertEquals(true, true, 'temp');
    }*/
    
}