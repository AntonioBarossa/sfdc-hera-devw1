@IsTest
public with sharing class HDT_BA_DeltaSelfReadingManagementTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    @TestSetup
    static void makeData(){
        /* List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPointList[0].CommoditySector__c = 'Gas';
        insert servPointList;
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        insert caseList; */
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        
        ServicePoint__c servPoint;
        servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
        servPoint.CommoditySector__c = 'Gas';
        insert servPoint;
        
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        
        //CASE
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactList[0].Id, servPoint.Id, contractList[0].id, ordList[0].id);
        for (Case c : caseList){
            c.Cluster__c = 'Autolettura';
            c.Type= 'Autolettura da cliente';
            c.Origin = 'Sportello';
        }
        insert caseList;
        HDT_UTL_DataFactoryTst.createReadingMeterCorrector(1, true, caseList[0].Id);
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Check preliminari OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP','Check preliminari OK',  rtId, rtName,'A','','','');
    }

    @IsTest
    public static void testEsitoOkDaSap(){
        Case myCase = [SELECT Id FROM Case];
        myCase.Phase__c = 'Esito OK da SAP';
        update myCase;
        System.debug('@@@@@phase ' + myCase.Phase__c);
        Test.startTest();
            HDT_BA_DeltaSelfReadingManagement selfReadingBatch = new HDT_BA_DeltaSelfReadingManagement();
            selfReadingBatch.execute(null);
        Test.stopTest();
        myCase = [SELECT Id,Note__c FROM Case WHERE Id = : myCase.Id];
        System.assertEquals('.', myCase.Note__c, 'Aggiornamento da Batch non funzionante');
    }

    @IsTest
    public static void testCheckPreliminariOk(){
        Case myCase = [SELECT Id FROM Case];
        
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        myCase.Phase__c = 'Check preliminari OK';
        myCase.Origin = 'IVR';
        update myCase;
        myCase = [SELECT Id,opinionrequestnumber__c, Phase__c  FROM Case WHERE Id = : myCase.Id];
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_SelfReadingsFacadeTst.myWebServiceMock());
        Test.startTest();
            HDT_BA_DeltaSelfReadingManagement selfReadingBatch = new HDT_BA_DeltaSelfReadingManagement();
            selfReadingBatch.execute(null);
        Test.stopTest();
        myCase = [SELECT Id,Phase__c FROM Case WHERE Id = : myCase.Id];
        System.assertEquals('Check preliminari OK', myCase.Phase__c, 'Aggiornamento da Batch non funzionante');
    }

    @IsTest
    public static void testCheckPreliminariOkWithCall(){
        Case myCase = [SELECT Id FROM Case];
        
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        myCase.Phase__c = 'Check preliminari OK';
        myCase.Origin = 'IVR';
        update myCase;
        wrts_prcgvr__AsyncJob__c job = new wrts_prcgvr__AsyncJob__c(
            wrts_prcgvr__ApexClassName__c = 'Test',
            wrts_prcgvr__JobType__c = 'Callout',
            wrts_prcgvr__JobItem__c = myCase.Id,
            wrts_prcgvr__Status__c = 'Queued',
            wrts_prcgvr__MethodName__c = 'execute'
        );
        insert job;
        myCase = [SELECT Id,opinionrequestnumber__c, Phase__c  FROM Case WHERE Id = : myCase.Id];
        System.debug('@@@@@phase ' + myCase.Phase__c);
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_SelfReadingsFacadeTst.myWebServiceMock());
        Test.startTest();
            HDT_BA_DeltaSelfReadingManagement selfReadingBatch = new HDT_BA_DeltaSelfReadingManagement();
            selfReadingBatch.execute(null);
        Test.stopTest();
        myCase = [SELECT Id,Phase__c FROM Case WHERE Id = : myCase.Id];
        System.assertEquals('Check preliminari OK', myCase.Phase__c, 'Aggiornamento da Batch non funzionante');
    }
}
