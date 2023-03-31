@isTest
public with sharing class HDT_BA_OrderDocumentalManagementTst {
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    @TestSetup
    static void setup(){
        //Istanzio PClick per permettere i cambi di fase del Case
        //HDT_UTL_DataFactoryTst.pClickInstance();
        //HDT_UTL_DataFactoryTst.pClickCasePhase();

        //Creo il custom settings per il Case
        EnvelopeReminderConfiguration__c cs = new EnvelopeReminderConfiguration__c();
        cs.Name='BA_OrderManagement';
        cs.CaseCommodity__c = '\'Ambiente\'';
        cs.OrderCommodity__c = '\'Ambiente\'';
        cs.CaseLastnDay__c = 0;
        cs.CasePhase__c = '\'In attesa validazione\'';
        cs.CaseType__c = '\'Cessazione\'';
        cs.EnableCaseQuery__c = true;
        cs.CalloutSyncCase__c = false;
        cs.EnableOrderQuery__c = true;
        cs.OrderLastnDay__c = 0;
        cs.OrderPhase__c = '\'In attesa validazione\'';
        cs.OrderType__c = '\'Modifica Tariffa\'';
        cs.CalloutSyncOrder__c = true;
        insert cs;
        
        //Creo l'Account Residenziale
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'MMS', 'G1 - MMS Persona fisica','Famiglie');
        accList[0].FiscalCode__c = 'BTQTVM40E24A562P';
        insert accList;
        Id accountId = accList[0].Id;

        //Creo il Contatto ed allineo il Codice fiscale
        List<Contact> contList = HDT_UTL_DataFactoryTst.createContact(1, false, accountId);
        contList[0].FiscalCode__c = accList[0].FiscalCode__c;
        contList[0].Company__c='MMS';
		contList[0].CompanyOwner__c='MMS';
        //Creo il Service Point Ambiente e gli assegno una ExternalKey
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        spList[0].Account__c = accountId;
        spList[0].CommoditySector__c = 'Ambiente';
        spList[0].RecordTypeId = utlConstants.SERVICEPOINT_RECORDTYPEID_PAMBIENTE;
        spList[0].SAPImplantCode__c = '40000001';
        //spList[0].GlobalMigrationKey__c = 'SP_40000001';
        ServicePoint__c spKey = new ServicePoint__c(SAPImplantCode__c = '40000001');

        //Creo il BillingProfile
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false,accountId);
        BillingProfile__c bpKey = new BillingProfile__c(ContractAccountCode__c = bpList[0].ContractAccountCode__c);
        //bpList[0].GlobalMigrationKey__c = 'BP_'+bpList[0].ContractAccountCode__c;

        //Creo il Contratto e gli assegno il Service Point e il Bp
        List<Contract> contrList = HDT_UTL_DataFactoryTst.createContract(1, false, accountId);
        contrList[0].ServicePoint__r = spKey;
        contrList[0].BillingProfile__r =  bpKey;
        //contrList[0].GlobalMigrationKey__c = 'CO_'+contrList[0].SAPContractCode__c;
        Contract contrKey = new Contract(SAPContractCode__c = contrList[0].SAPContractCode__c);

        //Creo il Case di Cessazione Ambiente con Indirizzo
        Case testCase=new Case();
        testCase.Phase__c='Bozza';
        testCase.Subject='Cessazione';
        testCase.Type='Cessazione';
        testCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_DisattivazioniTari').getRecordTypeId();
        testCase.CompanyOwner__c='HERA COMM';
        testCase.AccountId=accountId;
        testCase.ServicePoint__r=spKey;
        testCase.Contract__r=contrKey;
        testCase.BillingProfile__r=bpKey;
        testCase.Status='In Lavorazione';
        testCase.Phase__c='In attesa validazione';
        testCase.Cluster__c='Disattivazioni';
        testCase.DeliveryAddress__c = 'VIA DEI VESPRI 78, 98055 ITALIA';

        //Creo il Case di Cessazione Ambiente senza Indirizzo
        Case testCase2=new Case();
        testCase2.Phase__c='Bozza';
        testCase2.Subject='Cessazione';
        testCase2.Type='Cessazione';
        testCase2.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_DisattivazioniTari').getRecordTypeId();
        testCase2.CompanyOwner__c='HERA COMM';
        testCase2.AccountId=accountId;
        testCase2.ServicePoint__r=spKey;
        testCase2.Contract__r=contrKey;
        testCase2.BillingProfile__r=bpKey;
        testCase2.Status='In Lavorazione';
        testCase2.Phase__c='In attesa validazione';
        testCase2.Cluster__c='Disattivazioni';
        testCase2.DeliveryAddress__c = '';

        List<sObject> recordList = new List<sObject>();
        recordList.add(contList[0]);
        recordList.add(spList[0]);
        recordList.add(bpList[0]);
        recordList.add(contrList[0]);
        recordList.add(testCase);
        recordList.add(testCase2);
        insert recordList;
    }

    @isTest
    public static void testcheckContractualEnvelopeValidato(){
        Test.startTest();
        HDT_BA_OrderDocumentalManagement ba = new HDT_BA_OrderDocumentalManagement();
        Database.executeBatch(ba);
        Test.stopTest();
    }
}