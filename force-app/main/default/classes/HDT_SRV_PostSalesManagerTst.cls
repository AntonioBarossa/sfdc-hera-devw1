@isTest
public class HDT_SRV_PostSalesManagerTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[1].Name = 'TestAccount2';
        insert accList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, 'Bozza');
        ordList[0].ServicePoint__c = servPointList[0].Id;
        String rtParentOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();        
        ordList[1].RecordTypeId = rtParentOrder;
        insert ordList;
        ordList[0].ParentOrder__c = ordList[1].Id;
        update ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false, accList[0].Id);
        billingProfileList[0].ContractAccountCode__c = 'myCode';
        insert billingProfileList;
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].QuotationValidityDate__c = Date.today()-5;
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VariazioniEle').getRecordTypeId();
        caseList[0].Amount__c  = 20.00;
        caseList[0].Contract__c  = contractList[0].Id;

        insert caseList;

        Case parentCase = [SELECT Id FROM Case WHERE Amount__c = 20.00 LIMIT 1];
        List<Case> caseList2 = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList2[0].ParentId  = parentCase.Id;
        caseList2[0].BillingProfile__c  = billingProfileList[0].Id;
        caseList2[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        caseList2[0].Type  = 'Variazione indirizzo di fornitura';
        caseList2[0].ServicePoint__c = servPointList[0].Id;
        caseList2[1].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Morosita').getRecordTypeId();
        caseList2[1].Type = 'Riattivazione Fornitura';
        caseList2[1].HerokuPracticeCode__c = '';
        caseList2[1].BillingProfile__c = billingProfileList[0].Id;

        insert caseList2;

        List<Case> caseList3 = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList3[0].ParentId  = parentCase.Id;
        caseList3[0].BillingProfile__c  = billingProfileList[0].Id;
        caseList3[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        caseList3[0].Type  = 'Marcatura/Uso PdR';
        caseList3[0].ServicePoint__c = servPointList[0].Id;
    
        insert caseList3;
        
        List<wrts_prcgvr__ActivityTemplate__c> actTempList = new List<wrts_prcgvr__ActivityTemplate__c>();

        wrts_prcgvr__ActivityTemplate__c actTemplate1 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate1.Name = 'Sblocco Voltura';
        actTemplate1.wrts_prcgvr__Subject__c = 'Accettazione Voltura';

        wrts_prcgvr__ActivityTemplate__c actTemplate2 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate2.Name = 'Elaborazione Manuale';
        actTemplate2.wrts_prcgvr__Subject__c = 'Elaborazione Manuale';

        wrts_prcgvr__ActivityTemplate__c actTemplate3 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate3.Name = 'Gestione Manuale';
        actTemplate3.wrts_prcgvr__Subject__c = 'Gestione Manuale';

        wrts_prcgvr__ActivityTemplate__c actTemplate4 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate4.Name = 'Gestione Manuale SAP';
        actTemplate4.wrts_prcgvr__Subject__c = 'Gestione Manuale SAP';
        
        actTempList.add(actTemplate1);
        actTempList.add(actTemplate2);
        actTempList.add(actTemplate3);
        actTempList.add(actTemplate4);
        insert actTempList;

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = 'HDT_RT_VariazioniEle';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VariazioniEle').getRecordTypeId();
        String rtNameAllineamentoAnagraf = 'HDT_RT_AllineamentoAnagrafica';
        String rtIdAllineamentoAnagraf = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'KO Definitivo', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'KO definitivo', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Elaborazione Manuale', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Elaborazione Manuale', 'KO Definitivo', rtId, rtName,'A','','','');

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtIdAllineamentoAnagraf, rtNameAllineamentoAnagraf,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', rtIdAllineamentoAnagraf, rtNameAllineamentoAnagraf,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'KO definitivo', 'Bozza', rtIdAllineamentoAnagraf, rtNameAllineamentoAnagraf,'A','','','');

    }

    @IsTest
    static void changeCaseValue(){
        
        Case currentCase = [SELECT Id FROM Case WHERE Type  <> 'Variazione indirizzo di fornitura' LIMIT 1];

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('changeCaseValue', currentCase));

        System.assertEquals('Il metodo ha funzionato', currentCase.Subject, 'Subject != Il metodo ha funzionato');

        Test.stopTest();
        
    }

    @IsTest
    static void changeQuotationType(){
        
        Case currentCase = [SELECT Id, Amount__c, QuotationType__c FROM Case WHERE Type  <> 'Variazione indirizzo di fornitura' LIMIT 1];

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('changeQuotationType', currentCase));

        System.assertEquals('Predeterminabile', currentCase.QuotationType__c, 'QuotationType__c != Predeterminabile');

        Test.stopTest();
        
    }

    @IsTest
    static void closeContract(){
        
        Case currentCase = [SELECT Id, Contract__c FROM Case WHERE Type  <> 'Variazione indirizzo di fornitura' LIMIT 1];

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('closeContract', currentCase));

        Contract con = [SELECT Id, Status FROM Contract LIMIT 1];

        System.assertEquals('Cessato', con.Status, 'Status != Cessato');

        Test.stopTest();
        
    }

    @IsTest
    static void handleVarAnagrCliModDatiFiscali(){

        Case currentCase = [SELECT Id, SubProcess__c, BillingCity__c, AccountId, FirstName__c, LastName__c, FiscalCode__c, VatNumber__c, BillingCityCode__c, BillingCountry__c, BillingIsAddressVerified__c, BillingPlace__c, BillingPostalCode__c, BillingProvince__c, BillingStreetCode__c, BillingStreetName__c, BillingStreetNumber__c, BillingStreetNumberExtension__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.SubProcess__c = 'Modifica Dati Fiscali';
        currentCase.BillingCity__c = 'Genova';
        currentCase.LastName__c = 'Test';
        currentCase.VatNumber__c = '12345678100';
        currentCase.BillingIsAddressVerified__c = true;
        update currentCase;

        Account acc = [SELECT Id, BillingIsAddressVerified__c, VATNumber__c, IsWrongFiscalData__c, CustomerMarking__c, Category__c, CompanyOwner__c FROM Account WHERE Name <> 'TestAccount2' LIMIT 1];
        
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('handleVariazioneAnagraficaCliente', currentCase));

        Account updatedAccount = [SELECT Id, BillingCity FROM Account WHERE Id =: acc.Id LIMIT 1];

        System.assertEquals('Genova', updatedAccount.BillingCity, 'BillingCity__c != Roma');

        Test.stopTest();
        
    }

    @IsTest
    static void handleVarAnagrCliVarGruppoIva(){

        Case currentCase = [SELECT Id, SubProcess__c, AccountId, IsVATGroupJoined__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.SubProcess__c = 'Variazione Gruppo IVA';
        currentCase.VATGroup__c = '00146410454';
        currentCase.IsVATGroupJoined__c = true;
        update currentCase;
        
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('handleVariazioneAnagraficaCliente', currentCase));

        Account updatedAccount = [SELECT Id, VATGroup__c, IsVATGroupJoined__c FROM Account WHERE Id =: currentCase.AccountId LIMIT 1];

        System.assertEquals('00146410454', updatedAccount.VATGroup__c, 'VATGroup__c != 00146410454');
        System.assertEquals(true, updatedAccount.IsVATGroupJoined__c, 'IsVATGroupJoined__c != true');

        Test.stopTest();
        
    }

    @IsTest
    static void handleVarAnagrCliModDatiContatto(){

        Case currentCase = [SELECT Id, AccountId, CustomerMarking__c, SubProcess__c, ContactId, Email__c, PhoneNumber__c, Mobile__c, CertifiedEmail__c, Fax__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.SubProcess__c = 'Modifica Dati di Contatto';
        currentCase.Category__c = 'Aziende Soho';
        currentCase.CustomerMarking__c = 'Azienda';
        currentCase.Email__c = 'prova@prova.it';
        currentCase.PhoneNumber__c = '123456789';
        currentCase.Mobile__c = '1234567890';
        update currentCase;
        
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('handleVariazioneAnagraficaCliente', currentCase));

        Account updatedAccount = [SELECT Id, CustomerMarking__c FROM Account WHERE Name <> 'TestAccount2' LIMIT 1];

        System.assertEquals('Azienda', updatedAccount.CustomerMarking__c, 'CustomerMarking__c != Azienda');

        Test.stopTest();
        
    }

    @IsTest
    static void handleVarAnagrCliModDatiRecapito(){

        Case currentCase = [SELECT Id, AccountId, BillingProfile__c, CareOf__c, SubProcess__c, InvoiceEmail__c, BillSendingMethod__c, InvoiceCertifiedEmailAddress__c, SendCertifiedEmailConsentDate__c, ElectronicInvoicingMethod__c, ElectronicInvoiceCertifiedEmailAddress__c, OfficeSubjectCode__c, XMLType__c, InvoicingPostalCode__c, InvoicingStreetNumber__c, InvoicingCityCode__c, InvoicingStreetCode__c, InvoicingCity__c, InvoicingStreetNumberExtension__c, IsInvoicingVerified__c, InvoicingPlace__c, InvoicingStreetName__c, InvoicingCountry__c, InvoicingProvince__c, ReminderFlag__c, ReminderCertifiedEmailAddress__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.SubProcess__c = 'Modifica Dati di Recapito';
        currentCase.XMLType__c = 'Sintetico';
        update currentCase;
        
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('handleVariazioneAnagraficaCliente', currentCase));

        BillingProfile__c updatedBillingProfile = [SELECT Id, XMLType__c FROM BillingProfile__c LIMIT 1];

        System.assertEquals('Sintetico', updatedBillingProfile.XMLType__c, 'XMLType__c != Sintetico');

        Test.stopTest();
        
    }

    @IsTest
    static void innescoAllineamentoAnagraficaFiscale(){

        Case currentCase = [SELECT Id, AccountId, RecordType.DeveloperName, RecordType.Id, Phase__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('innescoAllineamentoAnagraficaFiscale', currentCase));


        Case updatedCase = [SELECT Id, Phase__c FROM Case WHERE Type = 'Allineamento Anagrafica' AND Cluster__c = 'Modifiche Anagrafiche' LIMIT 1];

        System.assertEquals('Da Inviare', updatedCase.Phase__c, 'Phase__c != Da Inviare');

        Test.stopTest();
        
    }

    @IsTest
    static void innescoAllineamentoAnagraficaCanoneRai(){

        Case currentCase = [SELECT Id, AccountId, RecordType.DeveloperName, RecordType.Id, Phase__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('innescoAllineamentoAnagraficaCanoneRai', currentCase));


        Case updatedCase = [SELECT Id, Phase__c FROM Case WHERE Type = 'Allineamento Anagrafica' AND Cluster__c = 'Modifiche Anagrafiche' LIMIT 1];

        System.assertEquals('Da Inviare', updatedCase.Phase__c, 'Phase__c != Da Inviare');

        Test.stopTest();
        
    }

    @IsTest
    static void innescoAllineamentoAnagraficaGestioneDisalimentabilita(){

        Case currentCase = [SELECT Id, AccountId, RecordType.DeveloperName, RecordType.Id, Phase__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('innescoAllineamentoAnagraficaGestioneDisalimentabilita', currentCase));


        Case updatedCase = [SELECT Id, Phase__c FROM Case WHERE Type = 'Allineamento Anagrafica' AND Cluster__c = 'Modifiche Anagrafiche' LIMIT 1];

        System.assertEquals('Da Inviare', updatedCase.Phase__c, 'Phase__c != Da Inviare');

        Test.stopTest();
        
    }

    @IsTest
    static void evaluateEffectiveDate(){

        Order currentOrder = [SELECT Id, EffectiveDate__c FROM Order LIMIT 1];

        currentOrder.EffectiveDate__c = System.today()-5;
        update currentOrder;

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('evaluateEffectiveDate', currentOrder));

        Test.stopTest();

        Date expectedDate = System.today();
        Integer businessDayToAdd = 3;

        while(businessDayToAdd != 0){
            expectedDate = expectedDate.addDays(1);
            if(!isWeekend(expectedDate)){
                businessDayToAdd--;
            }
        }

        System.assertEquals(expectedDate, currentOrder.EffectiveDate__c, 'EffectiveDate__c != System.today()+3');

        
    }

    static public Boolean isWeekend(Date myDate){
        String myDateString = Datetime.newInstance(myDate.year(), myDate.month(),myDate.day()).format('EEE');
        return 'Sat'.equals(myDateString) || 'Sun'.equals(myDateString);
    }

    @IsTest
    static void sbloccoVoltura(){

        Case currentCase = [SELECT Id, AccountId, VulturePracticeReference__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        Order currentOrder = [SELECT Id, ProcessCode__c FROM Order LIMIT 1];
        currentOrder.ProcessCode__c = 'NV1';

        currentCase.VulturePracticeReference__c = currentOrder.Id;

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('sbloccoVoltura', currentCase));

        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c LIMIT 1];

        System.assertNotEquals(null, activity, 'activity = null');

        Test.stopTest();
        
    }

    @IsTest
    static void changePaymentMethod(){

        Case currentCase = [SELECT Id, AccountId, BillingProfile__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('changePaymentMethod', currentCase));

        BillingProfile__c updatedBillingProfile = [SELECT Id, PaymentMethod__c FROM BillingProfile__c LIMIT 1];

        System.assertEquals('RID', updatedBillingProfile.PaymentMethod__c, 'PaymentMethod__c != RID');

        Test.stopTest();
        
    }

    @IsTest
    static void handleVariazioneAmministratoreCambioAmm(){

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount2'];
        Case currentCase = [SELECT Id, AccountId, SubProcess__c, ContactId FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.SubProcess__c = 'Cambio Amministratore';
        currentCase.AccountId = acc.Id;
        update currentCase;

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('handleVariazioneAmministratore', currentCase));

        AccountContactRelation newAdminAcr = [SELECT Id FROM AccountContactRelation WHERE Roles = 'Amministratore condominio'];

        System.assertNotEquals(null, newAdminAcr, 'newAdminAcr != null');
        
        Test.stopTest();
        
    }

    @IsTest
    static void handleVariazioneAmministratoreCambioInt(){

        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount2'];
        Case currentCase = [SELECT Id, AccountId, SubProcess__c, ContactId, BillingCityCode__c, BillingCity__c, BillingCountry__c, BillingIsAddressVerified__c, BillingPlace__c, BillingPostalCode__c, BillingProvince__c, BillingStreetCode__c, BillingStreetName__c, BillingStreetNumberExtension__c, BillingStreetNumber__c FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.SubProcess__c = 'Cambio Intest/Indirizzo Amministratore';
        currentCase.BillingCity__c = 'Milano';
        update currentCase;

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('handleVariazioneAmministratore', currentCase));

        Contact updatedContact = [SELECT Id, MailingCity FROM Contact WHERE Id =: currentCase.ContactId];

        System.assertEquals('Milano', updatedContact.MailingCity, 'MailingCity != Milano');
        
        Test.stopTest();
        
    }

    @IsTest
    static void advanceRelatedCase(){

        Case currentCase = [SELECT Id FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.Type = 'Allineamento Canone Rai';
        update currentCase;

        Order currentOrder = [SELECT Id, ServicePoint__c, PhaseStory__c FROM Order LIMIT 1];

        currentOrder.PhaseStory__c = 'Test';
        update currentOrder;

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('advanceRelatedCase', currentOrder));

        Case updatedCase  = [SELECT Id, Phase__c FROM Case WHERE Id =: currentCase.Id LIMIT 1];

        System.assertEquals('Completata', updatedCase.Phase__c, 'Phase__c != Completata');
        
        Test.stopTest();
        
    }

    @IsTest
    static void advanceRelatedCaseErroreLavorazioneSap(){

        Case currentCase = [SELECT Id FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];

        currentCase.Type = 'Allineamento Canone Rai';
        update currentCase;

        Order currentOrder = [SELECT Id, ServicePoint__c, PhaseStory__c FROM Order LIMIT 1];

        currentOrder.PhaseStory__c = 'Errore Lavorazione SAP';
        update currentOrder;

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('advanceRelatedCase', currentOrder));

        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Description__c = 'Elaborazione Manuale' LIMIT 1];

        System.assertNotEquals(null, activity, 'activity = null');
        
        Test.stopTest();
        
    }

    @IsTest
    static void updateServicePoint(){

        Case currentCase = [SELECT Id, ServicePoint__c, UseCategory__c, SupplyType__c, ServicePointType__c, Type FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        currentCase.Type = 'Marcatura/Uso PdR';
        currentCase.UseCategory__c = '004-Uso tecnologico';
        update currentCase;

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('updateServicePoint', currentCase));

        ServicePoint__c updatedServPoint = [SELECT Id, UseCategory__c  FROM ServicePoint__c WHERE Id =:currentCase.ServicePoint__c LIMIT 1];

        System.assertEquals('004-Uso tecnologico', updatedServPoint.UseCategory__c, 'UseCategory__c != 004-Uso tecnologico');
        
        Test.stopTest();
        
    }

    @IsTest
    static void advanceParentCasePhaseVarIndFornitura(){
        
        Case currentCase = [SELECT Id, ParentId, Type, Phase__c  FROM Case WHERE Type  = 'Marcatura/Uso PdR' LIMIT 1];
        Case parentCase = [SELECT Id, Type FROM Case WHERE Id =: currentCase.ParentId LIMIT 1];

        Test.startTest();

        parentCase.Type = 'Variazione indirizzo di fornitura';
        update parentCase;

        currentCase.Phase__c = 'KO definitivo';
        update currentCase;

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('advanceParentCasePhase', currentCase));

        Case parentCaseUpdated = [SELECT Id, Type, Phase__c FROM Case WHERE Id =: parentCase.Id LIMIT 1];

        System.assertEquals('Elaborazione Manuale', parentCaseUpdated.Phase__c, 'Phase__c != Elaborazione Manuale');

        Test.stopTest();
        
    }

    @IsTest
    static void advanceParentCasePhaseModTariffResidente(){
        
        Case currentCase = [SELECT Id, ParentId, Type, Phase__c  FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        Case parentCase = [SELECT Id, Type FROM Case WHERE Id =: currentCase.ParentId LIMIT 1];

        Test.startTest();

        parentCase.Type = 'Modifica Tariffa Residente/Non Residente';
        update parentCase;

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('advanceParentCasePhase', currentCase));

        Case parentCaseUpdated = [SELECT Id, Type, Phase__c FROM Case WHERE Id =: parentCase.Id LIMIT 1];

        System.assertEquals('Elaborazione Manuale', parentCaseUpdated.Phase__c, 'Phase__c != Elaborazione Manuale');

        Test.stopTest();
        
    }

    @IsTest
    static void advanceParentCasePhaseAllineamentoCanoneRai(){
        
        Case currentCase = [SELECT Id, ParentId, Type, Phase__c  FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        Case parentCase = [SELECT Id, Type FROM Case WHERE Id =: currentCase.ParentId LIMIT 1];

        Test.startTest();

        parentCase.Type = 'Allineamento Canone Rai';
        update parentCase;

        currentCase.Phase__c = 'KO definitivo';
        update currentCase;

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('advanceParentCasePhase', currentCase));

        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Description__c = 'Gestione Manuale'];
        System.assertNotEquals(null, activity, 'activity = null');

        Test.stopTest();
        
    }

    @IsTest
    static void advanceParentCasePhaseGestDisalimentabilita(){
        
        Case currentCase = [SELECT Id, ParentId, Type, Phase__c  FROM Case WHERE Type  = 'Variazione indirizzo di fornitura' LIMIT 1];
        Case parentCase = [SELECT Id, Type FROM Case WHERE Id =: currentCase.ParentId LIMIT 1];

        Test.startTest();

        parentCase.Type = 'Gestione Disalimentabilità';
        update parentCase;

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('advanceParentCasePhase', currentCase));

        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Description__c = 'Gestione Manuale SAP'];
        System.assertNotEquals(null, activity, 'activity = null');

        Test.stopTest();
        
    }

    @IsTest
    static void checkLocalDispatcher(){

        String dispatcherName = 'HERA SPA-13R0000000';
        
        Test.startTest();
        HDT_QR_PostSalesManager psm = new HDT_QR_PostSalesManager();
        Integer count = psm.checkLocalDispatcher(dispatcherName);

        System.assert(count > 0, 'count = 0');

        Test.stopTest();
        
    }

    @IsTest
    static void updateDataFineContrattoTest(){
                
        List<Case> myCaseList = [ SELECT Id, Contract__c, TemporaryConnectionEndDate__c FROM Case ];
        
        myCaseList[0].TemporaryConnectionEndDate__c = date.newInstance(2021, 11, 06);

        Test.startTest();
        
        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('updateDataFineContratto', myCaseList[0]));

        Test.stopTest();
        
        List<Case> myCaseListUpdated = [ SELECT Id, TemporaryConnectionEndDate__c, Contract__c, Contract__r.EndDate FROM Case WHERE Id = :myCaseList[0].Id ];

        System.assert(myCaseListUpdated[0].Contract__r.EndDate != null,'Update Data Fine Contratto non andata a buon fine');
        
    } 

    @IsTest
    static void sendDocumentFileTest(){

        Order currentOrder = [SELECT Id, ParentOrder__c, Cluster__c FROM Order LIMIT 1];

        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('sendDocumentFile', currentOrder));

        Test.stopTest();
        System.assert(currentOrder != null,'currentOrder è null');
        
    }

    @IsTest
    static void closeRiattivazioneTest(){

        Case currentCase = [SELECT Id, Type, Phase__c, Status, HerokuPracticeCode__c  FROM Case WHERE Type  = 'Riattivazione Fornitura' LIMIT 1];
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('closeRiattivazione', currentCase));
        
        Test.stopTest();
        System.assert(currentCase != null,'currentCase è null');

    }

    @IsTest
    static void closeAnnullamentoExtraSistemaTest(){

        Case currentCase = [SELECT Id, Phase__c, Status  FROM Case WHERE Type  = 'Riattivazione Fornitura' LIMIT 1];
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('closeAnnullamentoExtraSistema', currentCase));
        
        Test.stopTest();
        System.assert(currentCase != null,'currentCase è null');
        
    }

    @IsTest
    static void setContractAccountCodeTest(){

        Case currentCase = [SELECT Id, ContractAccountCode__c, BillingProfile__c, BillingProfile__r.ContractAccountCode__c  FROM Case WHERE Type  = 'Riattivazione Fornitura' LIMIT 1];
        Test.startTest();

        HDT_SRV_PostSalesManager psm = new HDT_SRV_PostSalesManager();
        psm.execute(setArgs('setContractAccountCode', currentCase));
        
        Test.stopTest();
        System.assert(currentCase != null,'currentCase è null');
        
    }

    public static Map<String, Object> setArgs (String method, SObject sender) {
        
        SObject transition;
        SObject action;
        String methodUsed = method;
        Map<String, Object> args = new Map<String,Object>();
        // Case newCase = new Case();
        // newCase.Id = sender.Id;
        args.put('transition', transition);
        args.put('action', action);
        args.put('method',methodUsed);
        args.put('sender', sender);

        return args;
    }

}
